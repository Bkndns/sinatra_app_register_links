require 'rspec'
require_relative '../helpers'

describe "UrlValidator" do


	context 'Test for valid_url function Helper' do
		it "is valid url http://google.ru? must be True" do
			url = "http://google.ru"
			expect(Sinatra::App::Helpers.valid_url?(url)).to eq(true)
		end

		it "is valid url https://www.google.ru? must be True" do
			url = "https://www.google.ru"
			expect(Sinatra::App::Helpers.valid_url?(url)).to eq(true)
		end

		it "is valid url google.ru? must be False" do
			url = "google.ru"
			expect(Sinatra::App::Helpers.valid_url?(url)).to be false
		end

		it "is valid url stackoverflow. without .domain? must be False" do
			url = "stackoverflow."
			expect(Sinatra::App::Helpers.valid_url?(url)).to be false
		end
	end


	context 'Test for get_url_only function Helper' do
		it "function must return only host url Ex: google.ru" do
			url = "http://google.ru"
			expect(Sinatra::App::Helpers.get_url_only(url)).to eq("google.ru")
		end

		it "function must return only host url Ex: google.ru" do
			url = "www.di.fm"
			expect(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(url))).to eq("di.fm")
		end

		it "function must return nil after normalize - bad domain (get_url_only(stackoverflow.)) Ex: stackoverflow." do
			url = "stackoverflow."
			expect(Sinatra::App::Helpers.get_url_only(Sinatra::App::Helpers.normalize_url(url))).to be_nil
		end

		it "function must return false - bad domain (get_url_only(stackoverflow.)) Ex: stackoverflow." do
			url = "stackoverflow."
			expect(Sinatra::App::Helpers.get_url_only(url)).to be false
		end
	end


	context 'Try to check validate JSON - valid_json? function Helper' do
		it "function must return true - Correct JSON" do
			json = '{
				"links": [
					"stackoverflow",
					"www.google.com",
					"https://ya2.ru",
					"https://ya3.ru",
					"example.ru",
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
				]
			}'
			expect(Sinatra::App::Helpers.valid_json?(json)).to be true 
		end

		it "function must return false - Incorrect JSON" do
			json = '{
				"links": [
					"stackoverflow",
					"www.google.com"
					https://ya2.ru"
					https://ya3.ru,
					"example.ru",
					"https://stackoverflow2.com/questions/11828270/how-to-exit-the-vim-editor"
				]
			}'
			expect(Sinatra::App::Helpers.valid_json?(json)).to be false
		end
	end


	context 'Url normalize test - normalize_url function Helper' do
		before :each do
			@urls = [
				'http://google.ru', 
				'https://google.ru',
				'http://www.google.ru', 
				'www.google.ru',
				'google.ru'
			]

			@urls_eq = [
				"http://google.ru",
				"https://google.ru",
				"https://google.ru",
				"https://google.ru",
				"https://google.ru"
			]
		end
		
		it "function try normalize 1 url Ex: www.google.ru = http://google.ru" do
			expect(Sinatra::App::Helpers.normalize_url(@urls[0])).to eq(@urls_eq[0])
		end
		it "function try normalize 2 url Ex: www.google.ru = http://google.ru" do
			expect(Sinatra::App::Helpers.normalize_url(@urls[1])).to eq(@urls_eq[1])
		end
		it "function try normalize 3 url Ex: www.google.ru = http://google.ru" do
			expect(Sinatra::App::Helpers.normalize_url(@urls[2])).to eq(@urls_eq[2])
		end
		it "function try normalize 4 url Ex: www.google.ru = http://google.ru" do
			expect(Sinatra::App::Helpers.normalize_url(@urls[3])).to eq(@urls_eq[3])
		end
		it "function try normalize 5 url Ex: www.google.ru = http://google.ru" do
			expect(Sinatra::App::Helpers.normalize_url(@urls[4])).to eq(@urls_eq[4])
		end
		it "function try normalize url Ex: stackoverflow. Must return false" do
			url = "stackoverflow."
			expect(Sinatra::App::Helpers.normalize_url(url)).to be false
		end
	end


end