require './app'

request = Rack::MockRequest.new(App)
response = request.get('/')
File.write('public/index.html', response.body)
