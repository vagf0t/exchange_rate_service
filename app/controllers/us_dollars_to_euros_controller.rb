
class UsDollarsToEurosController < ApplicationController
  def show
    date = params[:on]
    amount = params[:amount]

    raise ActionController::BadRequest.new, 'No date, provided.' if date.blank?
    begin
      date = Date.strptime(date, '%Y-%m-%d')
    rescue
      raise ActionController::BadRequest.new, 'Bad format of date, provided.'
    end

    raise ActionController::BadRequest.new, 'No amount, provided.' if amount.blank?
    begin
      amount = amount.to_f
      raise ActionController::BadRequest.new, 'Invalid amount, provided.' if amount <= 0
    rescue
      raise ActionController::BadRequest.new, 'Invalid amount, provided.'
    end

    render json: ExchangeRateConverter.convert(date, amount)
  end
end
