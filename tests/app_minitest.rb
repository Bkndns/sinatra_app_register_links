require 'minitest/autorun'

require_relative "../helpers"
require_relative "../controller"

class TestUrlValidator < Minitest::Test

	def setup
		@url_wh = "funbox.ru"
		@url_www = "www.funbox.ru"
		@url_fail = "https//funbox.ru/"
		@url_http = "http://funbox.ru/"
		@url = "https://funbox.ru/"
		@url2 = "https://www.funbox.ru/"
		@url_inval = "stackoverflow."

		@app_object = Controller.new()
		@timestamp_true = @app_object.timestamp
		@status_timestamp_len = "[Error] Переданный timestamp в переменную from или to является неверным (10 цифр)"
		@status_from_to_empty = "[Error] Требуется указать переменные from и to"
	end

	def test_add_link
		test_link = "https://funbox.ru"
		link_wh = "funbox.ru"
		check = @app_object.add_link(test_link)
		assert_equal(check, [@timestamp_true, link_wh])
	end

	def test_add_link_nil
		test_link = "funbox.r"
		check = @app_object.add_link(test_link)
		assert_nil(check)
	end

	# [check_links_by_timestamp]
	def test_check_links_by_timestamp_true
		timestamp_tr = 1592231777
		check = @app_object.check_links_by_timestamp(timestamp_tr, @timestamp_true)
		assert(check)
	end
			
	def test_check_links_by_timestamp_len_less_then_ten_sym
		timestamp_false = 159223177
		check = @app_object.check_links_by_timestamp(timestamp_false, @timestamp_true)
		assert_equal(@status_timestamp_len, check)
	end
	
	def test_check_links_by_timestamp_params_not_integer
		timestamp_false = "abirvalgqwe"
		check = @app_object.check_links_by_timestamp(timestamp_false, @timestamp_true)
		assert_equal(@status_timestamp_len, check)
	end
			
	def test_check_links_by_timestamp_params_is_empty
		check = @app_object.check_links_by_timestamp('', @timestamp_true)
		assert_equal(@status_from_to_empty, check)
	end
	# [check_links_by_timestamp]


end