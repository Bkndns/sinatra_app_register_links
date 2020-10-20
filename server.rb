# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'time'
require 'dotenv'
require 'redis'

require_relative './helpers'
require_relative './controller'

Dotenv.load

class App < Sinatra::Application

  set :root, File.dirname(__FILE__)
  set :static, true
  # set :public_folder, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])

  helpers Sinatra::App
  helpers Helpers
  controller = Controller.new()
  

  
  ##### SERVER ROUTES #####
  get '/' do
    Helpers.build_response({ status: 'Hello, World!' }.to_json)
  end

  get '/visited_domains' do
    result = controller.get_data_visited_domains(request)
    Helpers.build_response(result.to_json)
  end
  
  post '/visited_links' do
    result = controller.post_data_visited_links(request)
    Helpers.build_response(result.to_json)
  end

  not_found do
    Helpers.not_found_json('404 Error. Url not found')
  end

  

  # запускаем сервер, если исполняется текущий файл
  run! if app_file == $PROGRAM_NAME
end
