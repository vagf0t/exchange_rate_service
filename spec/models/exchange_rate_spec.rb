
require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  describe '.for' do

    context 'the exchange rate is not found in DB' do
      it 'should call get_exchange_rate_from_ecb' do
        expect(ExchangeRate).to receive(:get_exchange_rate_from_ecb).
            with ExchangeRate.working_day(Date.today)
        ExchangeRate.for Date.today
      end
    end

    context 'the exchange rate is found in DB' do
      before do
        xr = ExchangeRate.new
        xr.on = ExchangeRate.working_day(Date.today)
        xr.rate = 1
        xr.save!
      end
      it 'should call get_exchange_rate_from_ecb' do
        expect(ExchangeRate).not_to receive(:get_exchange_rate_from_ecb).
            with ExchangeRate.working_day(Date.today)
        expect(ExchangeRate.for(Date.today)).to eq 1
      end
    end
  end

  describe '.working_day' do
    context 'Sunday' do
      before { expect_any_instance_of(Date).to receive(:sunday?).and_return true }

      it 'should return Friday' do
        expect(ExchangeRate.working_day(Date.today)).to eq Date.today - 2.days
      end
    end

    context 'Saturday' do
      before { expect_any_instance_of(Date).to receive(:saturday?).and_return true }

      it 'should return Friday' do
        expect(ExchangeRate.working_day(Date.today)).to eq Date.today - 1.days
      end
    end

    context 'working day' do
      before do
        expect_any_instance_of(Date).to receive(:saturday?).and_return false
        expect_any_instance_of(Date).to receive(:sunday?).and_return false
      end

      it 'should return Friday' do
        expect(ExchangeRate.working_day(Date.today)).to eq Date.today
      end
    end
  end

  describe '.create_or_update' do
    context 'create' do
      it 'should receive new' do
        expect(ExchangeRate).to receive(:new).and_call_original
        ExchangeRate.send :create_or_update, Date.today, 1
      end
    end

    context 'update' do
      before do
        xr = ExchangeRate.new
        xr.on = ExchangeRate.working_day(Date.today)
        xr.rate = 1
        xr.save!
      end

      it 'should not receive new' do
        expect(ExchangeRate).not_to receive(:new)
        ExchangeRate.send :create_or_update, Date.today, 1
      end
    end
  end

  describe '.get_exchange_rate_from_ecb' do
    it 'tries to fetch the exchange rate from csv' do
      expect(Net::HTTP).to receive(:get).with(URI(Setting.ecb_uri)).and_return 'foo'
      expect(CSV).to receive(:parse).with('foo', headers: true).and_return 'bar'
      expect(ExchangeRate).to receive(:get_exchange_rate_from).
          with('bar', Date.today, '1999-01-04'.to_date)
      ExchangeRate.get_exchange_rate_from_ecb Date.today
    end
  end

  describe '.get_exchange_rate_from' do
    context 'invalid date in row' do
      let(:csv_text) { File.read('spec\test_files\invalid_date.csv') }
      let(:csv) { CSV.parse(csv_text, headers: true) }

      it 'logs the error and parses the next row' do
        expect(Rails.logger).to receive(:info).with 'No exchange rate for invalid date: foo was parsed.'
        expect(ExchangeRate).to receive(:delay).and_call_original
        expect(ExchangeRate.get_exchange_rate_from csv,
                                                   '2017-11-02'.to_date,
                                                   '1999-01-04'.to_date).to eq 1.1645
      end
    end

    context 'invalid rate in row' do
      let(:csv_text) { File.read('spec\test_files\invalid_rate.csv') }
      let(:csv) { CSV.parse(csv_text, headers: true) }

      it 'logs the error and parses the next row' do
        expect(Rails.logger).to receive(:info).
            with 'No exchange rate for invalid exchange rate: bar was parsed.'
        expect(ExchangeRate).to receive(:delay).and_call_original
        expect(ExchangeRate.get_exchange_rate_from csv,
                                                   '2017-11-02'.to_date,
                                                   '1999-01-04'.to_date).to eq 1.1645
      end
    end

    context 'blank rate in row' do
      let(:csv_text) { File.read('spec\test_files\blank_rate.csv') }
      let(:csv) { CSV.parse(csv_text, headers: true) }

      it 'logs the error and parses the next row' do
        expect(Rails.logger).to receive(:info).
            with 'No exchange rate for invalid exchange rate:  was parsed.'
        expect(ExchangeRate).to receive(:delay).and_call_original
        expect(ExchangeRate.get_exchange_rate_from csv,
                                                   '2017-11-02'.to_date,
                                                   '1999-01-04'.to_date).to eq 1.1645
      end
    end

    context 'valid row' do
      let(:csv_text) { File.read('spec\test_files\valid.csv') }
      let(:csv) { CSV.parse(csv_text, headers: true) }

      it 'parses the rows and returns the proper rate' do
        expect(ExchangeRate).to receive(:delay).twice.and_call_original
        expect(ExchangeRate.get_exchange_rate_from csv,
                                                   '2017-11-03'.to_date,
                                                   '1999-01-04'.to_date).to eq 1.1646
      end
    end

    context 'rate in no row' do
      let(:csv_text) { File.read('spec\test_files\valid.csv') }
      let(:csv) { CSV.parse(csv_text, headers: true) }

      it 'parses the rows, stores them and raises a 404' do
        expect(ExchangeRate).to receive(:delay).twice.and_call_original
        expect{ExchangeRate.get_exchange_rate_from csv,
                                                   '2017-11-08'.to_date,
                                                   '1999-01-04'.to_date}.
            to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
