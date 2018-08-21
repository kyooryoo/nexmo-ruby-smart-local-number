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
  # params 'to' has the number which is called by the customer
  # locations dictionary uses recipient number as key to get location name
  location = locations[params['to']]
  # statuses dictionary uses location name as key to get status information
  status = statuses[location]
  # this respond_with function returns NCCO with status of location
  respond_with(location, status)
end

post '/city' do
  # read the request and parse into JSON
  body = JSON.parse(request.body.read)
  # retrieve DTMF from the request body and convert into integer
  selection = body['dtmf'].to_i
  # use DTMF-1 as index key to retrieve location name from statuses dictionary
  location = statuses.keys[selection-1]
  # get status information with location from statuses dictionary
  status = statuses[location]
  # returns NCCO with status of location
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
      # ask for input of DTMF to retrieve status of location
      'eventUrl': ["#{ENV['DOMAIN']}/city"],
      'timeOut': 10,
      'maxDigits': 1
    }
  ].to_json
end
