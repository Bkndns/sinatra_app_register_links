require __dir__ + '/server'
run App
# Rack::Handler.default.run(App, :Port => 4242)
use Rack::Reloader