require 'rumeme/extensions'
require 'rumeme/utils'
require 'rumeme/configuration'
require 'rumeme/message_status'
require 'rumeme/validity_period'
require 'rumeme/sms_message'
require 'rumeme/sms_reply'
require 'rumeme/sms_interface'
require 'rumeme/version'
require 'rumeme/message_media'
require 'rumeme/message_media_response'
require 'rumeme/build_xml_sms_interface'
require 'rumeme/xml_parser'

module Rumeme
  class << self
    attr_accessor :configuration

    def configure
      @configuration ||= Configuration.new
      yield @configuration

      fail 'unknown long_messages_strategy' unless [:split, :send, :cut].include?(@configuration.long_messages_strategy)
    end
  end
end
