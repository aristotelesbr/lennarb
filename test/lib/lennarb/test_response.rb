# frozen_string_literal: true

require 'test_helper'

class Lennarb::TestResponse < Minitest::Test
	def test_default_instance_variables
		response = Lennarb::Response.new

		assert_equal 404, response.status
		assert_empty(response.headers)
		assert_empty response.body
		assert_equal 0, response.length
	end

	def test_set_and_get_response_header
		response = Lennarb::Response.new

		response['location'] = '/'

		assert_equal '/', response['location']
	end

	def test_write_to_response_body
		response = Lennarb::Response.new

		response.write('Hello World!')

		assert_equal 'Hello World!', response.body.first
	end

	def test_set_response_status
		response = Lennarb::Response.new

		response.status = 200

		assert_equal 200, response.status
	end

	def test_set_response_content_type
		response = Lennarb::Response.new

		response['content-type'] = 'text/html'

		assert_equal 'text/html', response['content-type']
	end

	def test_set_response_content_length
		response = Lennarb::Response.new

		response['content-length'] = 12

		assert_equal 12, response['content-length']
	end

	def test_finish_response
		response = Lennarb::Response.new
		response['content-type'] = 'text/plain'

		response.finish

		assert_equal 0, response.length
		assert_equal 'text/plain', response['content-type']
	end
end
