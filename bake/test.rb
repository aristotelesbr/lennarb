# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Aristóteles Coutinho.

require 'open3'

# Run tests.
#
# @parameter test [String] the path to file
def test(test: nil)
	test_dir = 'test'

	all_tests_command = "Dir.glob(\"./#{test_dir}/**/test_*.rb\").each { require _1 }"
	test_command = test ? "ruby -I#{test_dir} #{test}" : "ruby -I#{test_dir} -e '#{all_tests_command}'"

	stdout, _stderr, _status = ::Open3.capture3(test_command)

	puts "Output padrão:\n#{stdout}"
end
