
require 'rails_helper'

RSpec.describe ExchangeRateConverter, type: :model do
  describe '.convert' do
    it 'should call for' do
      expect(ExchangeRate).to receive(:for).with(Date.today).and_return 1.56
      expect(ExchangeRateConverter.convert Date.today, 100).to eq (100 / 1.56).round(2)
    end
  end
end
