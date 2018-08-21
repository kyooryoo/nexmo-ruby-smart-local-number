require 'sinatra'
require 'json'
require 'dotenv/load'

locations = {
  ENV['INBOUND_NUMBER_1'] => 'Chicago',
  ENV['INBOUND_NUMBER_2'] => 'San Francisco',
}

statuses = {
  'Chicago'       => 'There are minor delays on the L Line. There are no further delays.',
  'San Francisco' => 'There are currently no delays',
  'Austin'        => 'There are currently no delays'
}

get '/answer' do
  location = locations[params['to']]
  status = statuses[location]
  respond_with(location, status)
end

post '/city' do
  body = JSON.parse(request.body.read)
  selection = body['dtmf'].to_i
  location = statuses.keys[selection-1]
  status = statuses[location]
  respond_with(location, status)
end

def respond_with(location, status)
  content_type :json
  return [
    {
      'action': 'talk',
      'text': "Current status for the #{location} Transport Authority:"
    },
    {
      'action': 'talk',
      'text': status
    },
    {
      'action': 'talk',
      'text': 'For more info, press 1 for Chicago, 2 for San Francisco, and 3 for Austin. Or hang up to end your call.',
      'bargeIn': true
    },
    {
      'action': 'input',
      'eventUrl': ["#{ENV['DOMAIN']}/city"],
      'timeOut': 10,
      'maxDigits': 1
    }
  ].to_json
end
