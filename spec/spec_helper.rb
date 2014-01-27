require 'rspec/collection_matchers'
require 'vcr'

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift lib

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.debug_logger = $stdout
end

RSpec.configure do |c|
  # c.extend VCR::RSpec::Macros
end

require 'rumeme'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end
