# frozen_string_literal: true

# Set environment
#
ENV['RACK_ENV'] ||= 'development'

# Extension for Array class
require 'lennarb/array_extensions'

# Base class for Lennarb
require 'lenna/base'
require 'lennarb/version'
