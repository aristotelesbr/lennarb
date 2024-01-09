# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Aristóteles Coutinho.

require 'test_helper'

module Lennarb
	class TestRequest < Minitest::Test
		def test_initialize
			request = Lennarb::Request.new({})

			assert_instance_of(Lennarb::Request, request)
		end

		def test_params
			request = Lennarb::Request.new({ 'QUERY_STRING' => 'foo=bar' })

			assert_equal({ 'foo' => 'bar' }, request.params)
		end

		def test_query_params
			request = Lennarb::Request.new({ 'QUERY_STRING' => 'foo=bar' })

			assert_equal({ 'foo' => 'bar' }, request.__send__(:query_params))
		end

		def test_query_params_with_empty_query_string
			request = Lennarb::Request.new({})

			assert_empty(request.__send__(:query_params))
		end

		def test_content_type
			request = Lennarb::Request.new({ 'CONTENT_TYPE' => 'application/json' })

			assert_equal('application/json', request.content_type)
		end

		def test_content_length
			request = Lennarb::Request.new({ 'CONTENT_LENGTH' => '42' })

			assert_equal('42', request.content_length)
		end

		def test_body
			request = Lennarb::Request.new({ 'rack.input' => StringIO.new('foo') })

			assert_equal('foo', request.body.read)
		end

		def test_body_with_empty_body
			request = Lennarb::Request.new({})

			assert_nil(request.body)
		end
	end
end
