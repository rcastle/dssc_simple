
module DsscSimple
  VERSION = '0.0.1.a'
end

begin
  require_relative 'dssc_simple/report'

rescue
  # Ruby 1.8 Falls back here
  require 'rubygems'

  require 'dssc_simple/report'
end

