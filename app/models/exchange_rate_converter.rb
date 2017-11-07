
class ExchangeRateConverter
  # @param [Object] amount
  def self.convert(date, amount)
    xr = ExchangeRate.for(date)
    amount /= xr
    amount.round(2)
  end
end