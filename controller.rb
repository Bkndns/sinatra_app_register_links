require 'time'
require 'dotenv'
require 'redis'

require_relative './helpers'

Dotenv.load

class Controller
	####################

	attr_accessor :redis, :status
	def initialize
		super
		@redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_POST'])
		@status = ""
	end

	def timestamp
		Time.now.to_i
	end

	def set_status(str)
		@status = str
	end

	def set_status_ok
		set_status("ok")
	end

	def check_links_by_timestamp(from, to)
		from_str = from.to_s
		to_str = to.to_s

		if from_str.empty? || to_str.empty?
			status = set_status("[Error] Требуется указать переменные from и to")
		elsif from_str.length < 10 || to_str.length < 10
			status = set_status("[Error] Переданный timestamp в переменную from или to является неверным (10 цифр)")
		elsif from_str.to_i == 0 || to_str.to_i == 0
			status = set_status("[Error] Переданный timestamp в переменную from или to является неверным (10 цифр)")
		else
			true
		end
	end

	def add_link(link)
	  link = Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(link))
	  # p link
	  if link != false && !link.nil?
			str_for_redis = redis_add_format(link)
	  end
	end

	def redis_add_format(url)
	  fmt = [timestamp, url]
	end

	def redis_insert(key, val)
		redis.zadd(key, val) if val.kind_of?(Array)
	end

	def redis_get_result(key, from, to)
		redis.zrangebyscore(key, from, to)
	end

	def get_data_visited_domains(req)
		 new_hash = {}
		 params = req.params
		 time_to, time_from = params['to'], params['from']
		 
		 check_link = check_links_by_timestamp(time_from, time_to)

		 if check_link == true

			 result_from_redis = redis_get_result(ENV['REDIS_DATA_KEY'], time_from, time_to)
				 
			 p '##### REDIS #####'
			 p result_from_redis

			 new_hash = { "domains" => result_from_redis }
			 new_hash[:status] = set_status_ok

		 else
			 new_hash[:status] = check_link
		 end

		 new_hash

	end

	def post_data_visited_links(req)
		results = {}
		n_post_data = req.body.read
		# p n_post_data
		
		valid_json_check = Sinatra::App::Helpers.valid_json? n_post_data
		
		if valid_json_check
			
			object = JSON.parse n_post_data
			# puts JSON.pretty_generate(object)
		
			if object['links']
				if !object['links'].empty?

					object['links'].each { |url| redis_insert(ENV['REDIS_DATA_KEY'], add_link(url)) }
					results[:status] = set_status_ok
				else
					status = set_status("[Error] На сервер передан пустой массив links")
					results[:status] = status
				end
			else
				status = set_status("[Error] На сервер передан неверный формат JSON. Отсутствует массив links")
				results[:status] = status
			end
		
		else
			status = set_status("[Error] Произошла ошибка. Передан неправильный JSON. Проверьте синтаксис.")
			results[:status] = status
		end
		
		results

	end

	####################
end