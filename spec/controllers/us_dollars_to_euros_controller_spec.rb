require 'rails_helper'

RSpec.describe UsDollarsToEurosController, type: :controller do
  describe 'GET #show' do
    it 'renders the exchange rate with :on and :amount parameters' do
      expect(ExchangeRateConverter).to receive(:convert).with(Date.parse('2016-11-13'), 100.0).and_return 'yo!'
      response = get :show, params: { on: '2016-11-13', amount: '100' }
      expect(response.body).to eq 'yo!'
    end

    it 'raises a bad request exception with a non-date :on parameter' do
      expect { get :show, params: { on: 'foo', amount: '100' } }.to raise_exception(ActionController::BadRequest).with_message 'Bad format of date, provided.'
    end

    it 'raises a bad request exception with a negative :amount parameter' do
      expect { get :show, params: { on: '2016-11-13', amount: '-100' } }.to raise_exception(ActionController::BadRequest).with_message 'Invalid amount, provided.'
    end

    it 'raises a bad request exception with a zero :amount parameter' do
      expect { get :show, params: { on: '2016-11-13', amount: '0' } }.to raise_exception(ActionController::BadRequest).with_message 'Invalid amount, provided.'
    end

    it 'raises a no route exception without :on parameter and :amount present' do
      expect { get :show, params: { on: nil, amount: '100' } }.to raise_exception(ActionController::UrlGenerationError)
    end

    it 'raises a no route exception without :amount parameter and :on present' do
      expect { get :show, params: { on: '2016-11-13', amount: nil } }.to raise_exception(ActionController::UrlGenerationError)
    end

    it 'raises a no route exception without parameters' do
      expect { get :show }.to raise_exception(ActionController::UrlGenerationError)
    end
  end
end
