# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Aristóteles Coutinho.

ENV['RACK_ENV'] ||= 'development'

# Extension for Array class
#
require 'lennarb/array_extensions'

# Base class for Lennarb
#
require 'lenna/application'
require 'lennarb/version'
