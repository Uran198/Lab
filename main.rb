require 'sinatra'
require 'json'

get '/' do
	erb :index
end

post '/solve/?' do
	@data = JSON.parse(params['data'])
end

get '/solve/' do
	#erb :index
end

get '/:name' do
	@name = params['name']
end
