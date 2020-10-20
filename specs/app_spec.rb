require 'rspec'
require 'net/http'
require 'time'

require 'rest-client'

require_relative '../controller'
require_relative '../helpers'

describe "AppTester" do

	context 'Проверяем GET ссылку на возможные значения вместо timestamp' do
		before do
			@app_object = Controller.new()
			@timestamp_true = @app_object.timestamp
			@status_timestamp_len = "[Error] Переданный timestamp в переменную from или to является неверным (10 цифр)"
			@status_from_to_empty = "[Error] Требуется указать переменные from и to"
		end

		it "[add_link(link)] Проверяем результат работы вспомогательной функции" do
			test_link = "https://funbox.ru"
			link_wh = "funbox.ru"
			check = @app_object.add_link(test_link)
			expect(check).to eq([@timestamp_true, link_wh])
		end

		it "[add_link(link)] Проверяем результат работы вспомогательной функции - передадим неверный url. Ожидается nil" do
			test_link = "funbox."
			check = @app_object.add_link(test_link)
			expect(check).to be_nil
		end

		# [check_links_by_timestamp]
		it "[check_links_by_timestamp] правильный GET запрос к функции. Должен вернуть TRUE" do
			timestamp_tr = 1592231777
			check = @app_object.check_links_by_timestamp(timestamp_tr, @timestamp_true)
			expect(check).to be true
		end
		
		it "[check_links_by_timestamp] параметры from или to > 10 символов" do
			timestamp_false = 159223177
			check = @app_object.check_links_by_timestamp(timestamp_false, @timestamp_true)
			expect(check).to eq(@status_timestamp_len)
		end

		it "[check_links_by_timestamp] Попробуем передать в один из параметров не число? а буквы from или to > 10 символов" do
			timestamp_false = "abirvalgqwe"
			check = @app_object.check_links_by_timestamp(timestamp_false, @timestamp_true)
			expect(check).to eq(@status_timestamp_len)
		end
		
		it "[check_links_by_timestamp] параметры 'from' или 'to' пусты" do
			check = @app_object.check_links_by_timestamp('', @timestamp_true)
			expect(check).to eq(@status_from_to_empty)
		end
		# [check_links_by_timestamp]
	end


	context 'Проверяем POST ссылку на возможные значения, json, links, etc...' do
		before do
			@app_object = Controller.new()
			@timestamp_true = @app_object.timestamp
			@status_json_err = "[Error] Произошла ошибка. Передан неправильный JSON. Проверьте синтаксис."
			@status_json_err_links = "[Error] На сервер передан неверный формат JSON. Отсутствует массив links"
			@status_json_err_empty = "[Error] На сервер передан пустой массив links"
		end

		let(:json_add) { 
			'{
      	"links": [
					"stackoverflow",
					"www.google.com",
					"https://ya2.ru",
					"https://ya3.ru",
					"example.ru",
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
      	]
			}' 
		}
		let(:json_wlinks) { 
			'{
      	"link": [
					"stackoverflow",
					"www.google.com",
					"https://ya2.ru",
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
      	]
			}' 
		}
		let(:json_empty) { 
			'{
				"links": [],
				"status": "unkn"
			}' 
		}
		let(:json_add_fail) { 
			'{
      	"links": [
					"stackoverflow",
					"www.google.com",
					https://ya2.ru
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
      	]
			}' 
		}

		let(:url_post_links) { "http://localhost:9292/visited_links" }


		# [post_data_visited_links]

		it "[post_data_visited_links] Правильный запрос к функции. Должен вернуть TRUE" do
			begin
				response = RestClient.post url_post_links, json_add, {content_type: :json, accept: :json}
				result = JSON.parse(response.body.force_encoding("UTF-8"))
				expect(result).to eq({"status"=>"ok"})
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end
		
		it "[post_data_visited_links] Попробуем передать неверный JSON и получить ошибку" do
			begin
				response = RestClient.post url_post_links, json_add_fail, {content_type: :json, accept: :json}
				result = JSON.parse(response.body.force_encoding("UTF-8"))
				expect(result["status"]).to eq(@status_json_err)
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end

		it "[post_data_visited_links] Попробуем передать неверный JSON (без массива [links]) и получить ошибку" do
			begin
				response = RestClient.post url_post_links, json_wlinks, {content_type: :json, accept: :json}
				result = JSON.parse(response.body.force_encoding("UTF-8"))
				expect(result["status"]).to eq(@status_json_err_links)
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end

		it "[post_data_visited_links] Попробуем передать неверный JSON (пустой массив [links]) и получить ошибку" do
			begin
				response = RestClient.post url_post_links, json_empty, {content_type: :json, accept: :json}
				result = JSON.parse(response.body.force_encoding("UTF-8"))
				expect(result["status"]).to eq(@status_json_err_empty)
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end
		
		# [post_data_visited_links]
	end


	context 'GET && POST Requests / Response test' do


		let(:url_root_rack) { "http://localhost:9292/" }
		let(:url_post_links) { "http://localhost:9292/visited_links" }
		let(:url_get_links) { "http://localhost:9292/visited_domains" }
		let(:json_add) { '{
      "links": [
					"stackoverflow",
					"www.google.com",
					"https://ya2.ru",
					"https://ya3.ru",
					"example.ru",
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
      	]
			}' 
		}

		it "GET запрос к корню / вернёт" do
			uri = URI(url_root_rack)
			begin
				resp = JSON.parse(Net::HTTP.get(uri))
				expect(resp).to eq({"status" => "Hello, World!"})
				expect(Sinatra::App::Helpers.valid_json?(resp.to_json)).to be true
			rescue Errno::ECONNREFUSED
				puts "[GET Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			end
		end


		it "GET запрос на получение хранимых ссылок - проверка типа возвращаемого значения - JSON" do
			# ?from=1592080286&to=1592173497
			begin
				resp = RestClient.get url_get_links, {params: {'from': 1592080286, 'to' => Time.now.to_i}}
				resp_content_type = resp.headers[:content_type]
				expect(resp_content_type).to eq("application/json")
			rescue Errno::ECONNREFUSED
				puts "[GET Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			end
		end


		it "GET запрос на получение хранимых ссылок" do
			# ?from=1592080286&to=1592173497
			begin
				resp = RestClient.get url_get_links, {params: {'from': 1592080286, 'to' => Time.now.to_i}}
				resp_body = JSON.parse(resp.body)
				expect(resp_body).to include("domains")
			rescue Errno::ECONNREFUSED
				puts "[GET Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			end
		end


		it "GET запрос на получение хранимых ссылок - проверим стату код 200" do
			# ?from=1592080286&to=1592173497
			begin
				resp = RestClient.get url_get_links, {params: {'from': 1592080286, 'to' => Time.now.to_i}}
				status_code = resp.code
				expect(status_code).to eql(200)
			rescue Errno::ECONNREFUSED
				puts "[GET Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			end
		end

		#####

		it "POST запрос к url_post_links = Добавление ссылок" do
			begin
				response = RestClient.post url_post_links, json_add, {content_type: :json, accept: :json}
				result = JSON.parse(response.body.force_encoding("UTF-8"))
				expect(result).to eq({"status"=>"ok"})
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end


		it "POST запрос на проверку кода ответа 200" do
			begin
				resp = RestClient.post url_post_links, json_add, {content_type: :json, accept: :json}
				status_code = resp.code
				expect(status_code).to eql(200)
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end


		it "POST запрос на проверку типа ответа JSON" do
			begin
				response = RestClient.post url_post_links, json_add, {content_type: :json, accept: :json}
				content_type = response.headers[:content_type]
				expect(content_type).to eq("application/json")
			rescue Errno::ECONNREFUSED
				puts "[POST Response Error]. Connection fail. Failed to open TCP connection. Server is start?"
			rescue RestClient::InternalServerError
				puts "[POST Response Error]. 500 Internal Server Error. Серверная ошибка, возможно проблемы с базой данных Redis."
			end
		end

	end

	
end