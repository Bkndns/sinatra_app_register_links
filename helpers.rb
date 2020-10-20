require 'uri'
require 'json'

module Sinatra
	module App
		module Helpers
			class << self
				# 
				def build_response(body, content_type: "application/json", status: 200)
					[status, { "Content-Type" => content_type }, [body]]
				end
			
				def not_found(msg = "Not Found")
					[404, { "Content-Type" => "text/plain" }, [msg]]
				end
			
				def not_found_json(msg = "Not Found")
					[404, { "Content-Type" => "application/json" }, [{ status: msg }.to_json] ]
				end
				# 

				#####
				def get_url_only(dirty_url, _scheme = 'https')
					if dirty_url != false
						url = URI.parse(dirty_url)
						# url = url.host || url.path
						url = url.host.nil? ? false : url.host 
					end 
				end
		
				def valid_url?(url)
					url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
					url =~ url_regexp ? true : false
				end
		
				# Make https://site.ru URL
				# dirty_url is url (www.ya.ru, ya.ru, http://ya.ru)
				def normalize_url(dirty_url, scheme = 'https')
					url = URI.parse(dirty_url)
					url = URI.parse("#{scheme}://#{url}") if url.scheme.nil?
					host = url.host.downcase
					url = url.to_s.downcase
					url = host.start_with?('www.') ? "#{scheme}://#{host[4..-1]}" : url
					url = valid_url?(url) ? url : false # stackowerflow
				end
		
				def valid_json?(string)
					!!JSON.parse(string)
				rescue JSON::ParserError
					false
				end
				#####
			end
		end
	end
end