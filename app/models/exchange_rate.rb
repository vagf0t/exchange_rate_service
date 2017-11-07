
require 'Date'
require 'csv'
require 'net/http'

class ExchangeRate < ApplicationRecord
  def self.for(date)
    date = working_day date
    xr = ExchangeRate.find_by_on(date).try(:rate)
    xr = get_exchange_rate_from_ecb date if xr.blank?
    xr
  end

  def self.working_day(date)
    case
      when date.saturday?
        date - 1.days
      when date.sunday?
        date - 2.days
      else
        date
    end
  end

  def self.get_exchange_rate_from_ecb(date)
    uri = URI(Setting.ecb_uri)
    csv_text = Net::HTTP.get(uri)
    csv = CSV.parse(csv_text, headers: true)
    last_db_date = ExchangeRate.last.on
    get_exchange_rate_from csv, date, last_db_date
  end

  def self.get_exchange_rate_from(csv, date, last_db_date)
    xr = nil
    csv.each_with_index do |row, i|
      if i >= Setting.header_rows # do not parse the headers
        begin
          csv_date = Date.strptime(row[0], '%Y-%m-%d')
        rescue
          logger.info "No exchange rate for invalid date: #{row[0]} was parsed."
          next
        end
        begin
          raise StandardError if row[1].to_f <= 0 #csv file may contain blank values in the xr column
          csv_xr = row[1].to_f
        rescue
          logger.info "No exchange rate for invalid exchange rate: #{row[1]} was parsed."
          next
        end
        ExchangeRate.delay.create_or_update(csv_date, csv_xr)
        xr = csv_xr if csv_date == date
        break if csv_date <= last_db_date
      end
    end
    raise ActiveRecord::RecordNotFound if xr.nil? #This will respond with a 404
    xr
  end

  def self.create_or_update(csv_date, csv_xr)
    xr = ExchangeRate.find_by_on csv_date
    xr = ExchangeRate.new if xr.blank?
    xr.on = csv_date
    xr.rate = csv_xr
    xr.save!
  end
end

