class ExchangeRatesController < ApplicationController
  def show
    date = params[:on]
    raise ActionController::BadRequest.new, 'No date, provided.' if date.blank?
    begin
      date = Date.strptime(date, '%Y-%m-%d')
    rescue
      raise ActionController::BadRequest.new, 'Bad format of date, provided.'
    end
    render json: ExchangeRate.for(date)
  end
end
