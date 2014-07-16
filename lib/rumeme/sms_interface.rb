# encoding: UTF-8
require 'net/http'
require 'net/https'

module Rumeme
  # This is the main class used to interface with the M4U SMS messaging server.
  class SmsInterface
    class BadServerResponse < StandardError; end

    LONG_MESSAGES_PROCESSORS = {
      send: ->(message) { [message] },
      cut:  ->(message) { [message[0..159]] },
      split: ->(message) { Utils.split_message(message) }
    }

    def initialize(username = nil, password = nil)
      Rumeme.configuration.tap do |cfg|
        @username = username || cfg.username
        @password = password || cfg.password
        @use_message_id = cfg.use_message_id
        @secure = cfg.secure

        @long_messages_processor = LONG_MESSAGES_PROCESSORS.fetch(cfg.long_messages_strategy) do
          fail ArgumentError, 'invalid long_messages_strategy'
        end

        @replies_auto_confirm = cfg.replies_auto_confirm
      end

      @message_list = []
    end

    # Add a message to be sent.
    def add_message(args)
      check_message_args(args)

      phone_number = Utils.strip_invalid(args[:phone_number])
      messages = process_long_message(args[:message])

      @message_list.concat(messages.map { |msg| SmsMessage.new(args.merge(message: msg, phone_number: phone_number)) })
    end

    # Clear all the messages from the list.
    def clear_messages
      @message_list.clear
    end

    # Change the password on the local machine and server.
    # not implemented
    def change_password
      fail 'Not Implemented'
    end

    # Return the list of replies we have received.
    def check_replies
      response_message, response_code = post_data_to_server("CHECKREPLY2.0\r\n.\r\n")
      return unless response_code == 150

      messages = response_message.split("\r\n")[1..-2].map { |message_line| SmsReply.parse(message_line) } # check @use_message_id
      confirm_replies_received if @replies_auto_confirm && messages.size > 0

      messages
    end

    # sends confirmation to server
    def confirm_replies_received
      post_data_to_server "CONFIRM_RECEIVED\r\n.\r\n"
    end

    # Returns the credits remaining (for prepaid users only).
    def get_credits_remaining
      response_message, response_code = post_data_to_server("MESSAGES\r\n.\r\n")

      if response_message =~ /^(\d+)\s+OK\s+(\d+).+/
        if response_code != 100
          fail BadServerResponse, 'M4U code is not 100'
        end
        $2.to_i
      else
        fail BadServerResponse, "cant parse response: #{response_message}"
      end
    end

    # Sends all the messages that have been added with the add_message command.
    # returns boolean. true if successful, false if not.
    def send_messages
      post_string = @message_list.map(&:post_string).join
      text_buffer = "MESSAGES2.0\r\n#{post_string}.\r\n"
      response_message, response_code = post_data_to_server(text_buffer)  
      response_code == 100
    end

    # Sends all the messages that have been added with the add_message command.
    # Raises exception if not successful
    def send_messages!
      fail BadServerResponse, 'error during sending messages' unless send_messages
    end

    # The Block Numbers request is used to prevent the authenticated account
    # being able to send messages to the specified numbers in future.
    # @api public
    # @param numbers [Integer Array] the numbers to be blocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @example block_numbers[61410000001,61410000002] OR
    #   block_numbers([{number: '61410000001', uid: '1'},
    #   {number: '61410000002', uid: '2'}])
    # @return [Rumeme::MessageMediaResponse] The response object
    def block_numbers(numbers)
      xml_sms_interface = Rumeme::BuildXmlSmsInterface.new(@username, @password)
      xml = xml_sms_interface.block_numbers(numbers)
      Rumeme::MessageMedia.post_xml(xml)
    end

    # The Unblock Numbers request is used to remove existing number blocks.
    # @api public
    # @param numbers [Integer Array] the numbers to be blocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @example unblock_numbers[61410000001,61410000002] OR
    #   unblock_numbers([{number: '61410000001', uid: '1'},
    #   {number: '61410000002', uid: '2'}])
    # @return [Rumeme::MessageMediaResponse] The response object
    def unblock_numbers(numbers)
      xml_sms_interface = Rumeme::BuildXmlSmsInterface.new(@username, @password)
      xml = xml_sms_interface.unblock_numbers(numbers)
      Rumeme::MessageMedia.post_xml(xml)
    end

    # The Get Blocked Numbers request is used retrieve a list of numbers that
    # are currently blocked for the authenticated account.
    # @api public
    # @param numbers [Integer Array] the numbers to be blocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @param [Integer] Maximum number of results (numbers) to be returned
    # @return [Rumeme::MessageMediaResponse] The response object
    def get_blocked_numbers(max_results = false)
      xml_sms_interface = Rumeme::BuildXmlSmsInterface.new(@username, @password)
      xml = xml_sms_interface.get_blocked_numbers(max_results)
      Rumeme::MessageMedia.post_xml(xml)
    end

    private

    def check_message_args(args)
      fail ArgumentError, 'phone_number is empty' if args[:phone_number].blank?
      fail ArgumentError, 'message is empty' if args[:message].blank?
    end

    def process_long_message(message)
      return [message] if message.length <= 160
      @long_messages_processor.call(message)
    end

    def message_id_sign
      @use_message_id ? '#' : ''
    end

    def create_login_string # can be calculate once at initialization
      "m4u\r\nUSER=#{@username}#{message_id_sign}\r\nPASSWORD=#{@password}\r\nVER=PHP1.0\r\n"
    end

   
    def post_data_to_server(data)
      text_buffer = create_login_string + data

      response_message = Rumeme::MessageMedia.post_plain_text(text_buffer)

      response_message.match(/^(\d+)\s+/)
      response_code = $1.to_i

      [response_message, response_code]
    end
  end
end
