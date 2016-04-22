require 'sinatra'
require 'json'
require 'pry'
require 'base64'

def print_bod(body)
  # bod = JSON.load(body.read)
  # puts "#" * 10
  # if bod["contents"]
  #   bod["contents"] = Base64.decode64(bod["contents"])
  # end
  bod = body.read
  puts bod
  puts "#" * 10
end

get '/' do
  "Hello world"
end

get "/api/v1/users/me" do
  {:"agent-token" => "1234"}.to_json
end

post '/api/v2/check' do
  binding.pry
   print_bod(request.body)
  {success: true}.to_json
end

post '/api/v1/agent/heartbeat/:id' do
  print_bod(request.body)
  {success: true}.to_json
end

post '/api/v1/agent/servers' do
  print_bod(request.body)
  {uuid:"12345"}.to_json
end

put '/api/v1/agent/servers/:id' do
  print_bod(request.body)
  "OK"
end
