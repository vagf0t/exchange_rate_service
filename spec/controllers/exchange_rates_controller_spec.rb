require 'rails_helper'

RSpec.describe ExchangeRatesController, type: :controller do
  describe 'GET #show' do
    it 'renders the exchange rate with :on parameter' do
      expect(ExchangeRate).to receive(:for).with(Date.parse('2016-11-13')).and_return 'foo'
      response = get :show, params: { on: '2016-11-13' }
      expect(response.body).to eq 'foo'
    end

    it 'raises a bad request exception with a non-date :on parameter' do
      expect { get :show, on: 'foo' }.to raise_exception(ActionController::BadRequest).with_message 'Bad format of date, provided.'
    end

    it 'raises a bad request exception without :on parameter' do
      expect { get :show }.to raise_exception(ActionController::BadRequest).with_message 'No date, provided.'
    end
  end
end
