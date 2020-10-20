require 'net/http'
require 'uri'
require 'time'
require 'json'

# Файл для большей автоматизации и простого запуска

namespace :app do

	# Можно прописать в default
	desc "1 - Install all dependencies (Bundler)"
	task :binstall do
		system("bundle install")
	end

	# Можно было запустить сервер цепочкой после установки зависимостей. Но нет
	desc "2 - Start Rack Server"
	task :bserver_start do
		system("rackup")
	end

	desc "3 - Test Request to Rack Server"
	task :bserver_test_req do
		url = "http://localhost:9292"
  	uri = URI.parse(url)
  	response = Net::HTTP.get_response(uri)
		content = response.body
		p JSON.parse(content)
	end

	desc "4 - Insert Test data to Rack Server"
	task :dinsert_data do
		require 'rest-client'
		url_post_links = "http://localhost:9292/visited_links"
		json_add = '{
      "links": [
				"funbox.ru",
				"www.google.com",
				"https://ya.ru",
				"https://ya.ru?q=123",
				"funbox.ru",
				"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
      ]
		}' 
		begin
			response = RestClient.post url_post_links, json_add, {content_type: :json, accept: :json}
			result = JSON.parse(response.body.force_encoding("UTF-8"))
			p result
		rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
		rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
		end
	end

	desc "5 - Get data"
	task get_data: [:timestamp] do
		require 'rest-client'
		url_get_links = "http://localhost:9292/visited_domains"
		begin
			resp = RestClient.get url_get_links, {params: {'from': 1592080286, 'to' => @timestamp }}
			resp_body = JSON.parse(resp.body)
			puts JSON.pretty_generate(resp_body)
		rescue Errno::ECONNREFUSED
			puts "[GET Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
		end
	end

	task :timestamp do
		@timestamp = Time.now.to_i
	end

	desc "6 - Print curl GET request + timestamp now (for copy and paste in console)"
	task print_get_curl: [:timestamp] do
		puts "curl 'http://localhost:9292/visited_domains?from=1592080286&to=#{@timestamp}'"
	end

	desc "7 - Print curl POST request (for copy and paste in console)"
	task print_post_curl: [:timestamp] do
		puts "curl -v -H 'Content-type: application/json' -X POST -d '{ \"links\": [\"https://ya2.ru\", \"https://ya3.ru?q=123\", \"funbox.ru\", \"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor\"] }' http://localhost:9292/visited_links"
	end

	desc "8 - Run all minitests"
	task :run_minitests do
		puts "[run minitest url_validator_minitest...]"
		system("ruby tests/url_validator_minitest.rb")
		puts "[run minitest app...]"
		system("ruby tests/app_minitest.rb")
	end

	desc "9 - Run all RSpec Tests"
	task :run_rspecs do
		puts "[run rspec url_validator_spec...]"
		system("rspec specs/url_validator_spec.rb")
		# Можно было цепочкой запустить
		puts "[run rspec app...]"
		system("rspec specs/app_spec.rb")
	end



end