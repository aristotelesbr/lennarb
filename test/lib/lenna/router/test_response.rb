# frozen_string_literal: true

require 'test_helper'

require 'erb'
require 'minitest/mock'

module Lenna
  class Router
    class TestResponse < Minitest::Test
      def setup
        @res = Response.new
      end

      def test_with_invlaid_status
        assert_raises(::ArgumentError) { @res.put_status('404') }
      end

      def test_status
        assert_equal 200, @res.status
      end

      def test_put_status
        @res.put_status(404)

        assert_equal 404, @res.status
      end

      def test_with_invlaid_body
        assert_raises(::ArgumentError) { @res.put_body(123) }
      end

      def test_body
        assert_empty @res.body
      end

      def test_put_body
        @res.put_body('Hello')

        assert_equal ['Hello'], @res.body

        @res.put_body(['World'])

        assert_equal ['World'], @res.body
      end

      def test_with_invlaid_header
        assert_raises(::ArgumentError) { @res.put_header(123) }
      end

      def test_header_with_key
        @res.put_header('Content-Type', 'text/plain')

        assert_equal 'text/plain', @res.header('Content-Type')
      end

      def test_headers
        @res.put_header('Content-Type', 'text/plain')

        assert_equal({ 'Content-Type' => 'text/plain' }, @res.headers)
      end

      def test_put_header
        @res.put_header('Content-Type', ['text/plain', 'text/html'])

        assert_equal(
          { 'Content-Type' => 'text/plain, text/html' },
          @res.headers
        )
      end

      def test_put_headers
        @res.put_headers('Content-Type' => 'text/plain')

        assert_equal({ 'Content-Type' => 'text/plain' }, @res.headers)
      end

      def test_delete_header
        @res.put_header('Content-Type', 'text/plain')

        @res.remove_header('Content-Type')

        assert_empty @res.headers
      end

      def test_with_invlaid_cookieh
        assert_raises(::ArgumentError) { @res.put_cookie(123) }
      end

      def test_cookie_with_key
        @res.put_cookie('foo', 'bar')

        assert_equal 'bar', @res.cookie('foo')
      end

      def test_cookies
        @res.put_cookie('foo', 'bar')

        assert_equal({ 'foo' => 'bar' }, @res.cookies)
      end

      def test_put_cookie
        @res.put_cookie('foo', 'bar')

        assert_equal({ 'foo' => 'bar' }, @res.cookies)
      end

      # Content-Type

      def test_content_type
        @res.put_content_type('text/plain')

        assert_equal 'text/plain', @res.content_type
      end

      def test_content_type_with_charset
        @res.put_content_type('text/plain', charset: 'utf-8')

        assert_equal 'text/plain; charset=utf-8', @res.content_type
      end

      # Location

      # Redirection

      def test_redirect
        @res.redirect('/foo')

        assert_equal 302, @res.status
        assert_equal '/foo', @res.header('Location')
      end

      def test_redirect_with_status
        @res.redirect('/foo', status: 301)

        assert_equal 301, @res.status
        assert_equal '/foo', @res.header('Location')
      end

      # Formats

      def test_html
        @res.html('Hello')

        assert_equal ['Hello'], @res.body
        assert_equal 'text/html', @res.content_type
      end

      def test_json
        @res.json(data: { hello: 'World' })

        assert_equal ['{"hello":"World"}'], @res.body
        assert_equal 'application/json', @res.content_type
      end

      def test_render_raises_exception_when_template_not_found
        template_name = 'nonexistent_template'
        mock_path = 'fake/path'

        ::File.stub :exist?, false do
          assert_raises(::RuntimeError) do
            @res.render(template_name, path: mock_path)
          end
        end
      end

      def test_render_successfully_renders_template
        template_name     = 'existent_template'
        mock_path         = 'fake/path'
        fake_file_content = '<h1>Hello <%= name %></h1>'
        expected_html     = ['<h1>Hello World</h1>']
        expected_headers  = {
          'Content-Type' => 'text/html',
          'Content-Length' => '20'
        }
        expected_status = 200

        ::File.stub :exist?, true do
          ::File.stub :read, fake_file_content do
            ::ERB.stub :new, ::ERB.new(fake_file_content) do
              assert_equal(
                [expected_status, expected_headers, expected_html],
                @res.render(
                  template_name,
                  path: mock_path,
                  locals: { name: 'World' }
                )
              )
            end
          end
        end
      end
    end
  end
end
