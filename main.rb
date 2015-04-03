require 'sinatra'

get '/' do
	erb :index
end

get '/:name' do
	@name = params['name']
end
