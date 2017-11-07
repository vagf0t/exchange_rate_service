
require 'rails_helper'

RSpec.describe 'routes', type: :routing do
  it 'routes exchange_rates controller' do
    expect(get: '/exchange_rates/2017-11-5').to route_to(controller: 'exchange_rates', action: 'show', 'on'=>'2017-11-5')
  end

  it 'routes us_dollars_to_euros to the controller' do
    expect(get: '/us_dollars_to_euros/2017-11-5/100').to route_to(controller: 'us_dollars_to_euros', action: 'show', 'on'=>'2017-11-5', 'amount' => '100')
  end
end