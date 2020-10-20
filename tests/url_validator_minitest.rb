require 'minitest/autorun'

require_relative "../helpers"

class TestUrlValidator < Minitest::Test

	def setup
		@url_wh = "funbox.ru"
		@url_www = "www.funbox.ru"
		@url_fail = "https//funbox.ru/"
		@url_http = "http://funbox.ru/"
		@url = "https://funbox.ru/"
		@url2 = "https://www.funbox.ru/"
		@url_inval = "stackoverflow."
	end

	def test_valid_url_false
		assert(Sinatra::App::Helpers.valid_url?(@url_fail) == false)
	end

	def test_valid_url_true
		assert(Sinatra::App::Helpers.valid_url?(@url) == true)
		assert(Sinatra::App::Helpers.valid_url?(@url2) == true)
		assert(Sinatra::App::Helpers.valid_url?(@url_http) == true)
	end

	def test_valid_url_without_host
		assert(Sinatra::App::Helpers.valid_url?(@url_wh) == false)
		assert(Sinatra::App::Helpers.valid_url?(@url_www) == false)
	end

	def test_valid_url_without_host_and_normalize
		assert(Sinatra::App::Helpers.valid_url?(Sinatra::App::Helpers.normalize_url(@url_wh)) == true)
		assert(Sinatra::App::Helpers.valid_url?(Sinatra::App::Helpers.normalize_url(@url_www)) == true)
	end

	def test_check_invalid_url_normalize_false
		assert(Sinatra::App::Helpers.valid_url?(Sinatra::App::Helpers.normalize_url(@url_inval)) == false)
	end

	def test_invalid_url_normalize_false
		assert(Sinatra::App::Helpers.normalize_url(@url_inval) == false)
	end

	def test_get_url_only_and_normalize
		ethalon = "funbox.ru"
		assert(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url_wh)) == ethalon)
		assert(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url_www)) == ethalon)

		assert_nil(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url_fail)))
		assert_equal(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url)), ethalon)
		
		assert(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url2)) == ethalon)
		assert(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(@url_http)) == ethalon)
	end


end