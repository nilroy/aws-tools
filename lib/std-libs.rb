#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)

# Standard libraries
require 'base64'
require 'erb'
require 'logger'
require 'singleton'
require 'timeout'
require 'yaml'

# AWS libraries
require 'aws-sdk-ssm'


#Other 3rd party libraries
require 'awesome_print'
require 'optimist'
require 'uuid'
require 'pry-byebug'