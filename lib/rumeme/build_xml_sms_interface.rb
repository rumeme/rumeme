require 'nokogiri'

# Rumeme main module
module Rumeme
  # Build the XML for the XML API Interface
  class BuildXmlSmsInterface
    # load credentials from the configuration file
    def initialize(username = nil, password = nil)
      Rumeme.configuration.tap do |config|
        @username = username || config.username
        @password = password || config.password
      end
    end

    # The Block Numbers request is used to prevent the authenticated account
    # being able to send messages to the specified numbers in future.
    # @api public
    # @param numbers [Integer Array] the numbers to be blocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @example block_numbers[61410000001,61410000002] OR
    #   block_numbers([{number: '61410000001', uid: '1'},
    #   {number: '61410000002', uid: '2'}])
    # @return [String] the XML
    def block_numbers(numbers)
      xml = build_xml('blockNumbers')
      common_code_for_element_recipients(numbers, xml)
    end

    # The Unblock Numbers request is used to remove existing number blocks.
    # @api public
    # @param numbers [Integer Array] the number to be unblocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @example unblock_numbers[61410000001,61410000002] OR
    #   unblock_numbers([{number: '61410000001', uid: '1'},
    #   {number: '61410000002', uid: '2'}])
    # @return [String] the XML
    def unblock_numbers(numbers)
      xml = build_xml('unblockNumbers')
      common_code_for_element_recipients(numbers, xml)
    end

    # The Get Blocked Numbers request is used retrieve a list of numbers that
    # are currently blocked for the authenticated account.
    # @api public
    # @param [Integer] Maximum number of results (numbers) to be returned
    # @return [String] the XML
    def get_blocked_numbers(max_results = false)
      xml = build_xml('getBlockedNumbers')
      common_code_for_max_results(xml, :maximumRecipients, max_results)
    end

    # The Check Reports request is used to download delivery reports that are
    # waiting on the gateway. Delivery reports are downloaded for a specific
    # user account. A delivery report reports the delivery status of a sent
    # message. Delivery reports may only be obtained for SMS messages not voice
    # messages and must be requested explicitly in the Send Messages request
    # (Section 7.4).
    # Delivery reports will remain marked as unsent and will be downloaded each
    # time the Check Reports request is made until they are confirmed by the
    # user as having been received. See Section 7.12 for details on confirming
    # reports.
    # @api public
    # @param [Integer] Maximum number of results (reports) to be returned
    # @return [String] the XML
    def check_reports(max_results = false)
      xml = build_xml('checkReports')
      common_code_for_max_results(xml, :maximumReports, max_results)
    end

    # The Check User request is used to authenticate a user and obtain their account credit details
    # @api public
    # @return [String] the xml
    def check_user
      build_xml('checkUser', false).doc.root.to_xml
    end

    # The Confirm Replies request is used to confirm the receipt of reply
    # messages that were downloaded from the gateway. Replies that are
    # unconfirmed will be downloaded each time a Check Replies request is
    # made. When reply messages are confirmed they are marked as sent and will
    # not be downloaded again. It is not possible for a user to confirm
    # replies that do not belong to them.
    # Reply messages must be confirmed on an individual basis. Replies are
    # specified by their receipt ID. This receipt ID is the same receipt ID
    # that the reply message was assigned in the Check Replies response. The
    # receipt ID is specified by the attribute receiptId. See Section 7.7 for
    # details on the Check Replies response.
    # @api public
    # @param [Array] receipt IDs
    def confirm_replies(receipt_ids)
      xml = build_xml('confirmReplies')
      common_code_array_to_xml(xml, :replies, :reply, 'receiptId', receipt_ids)
    end

    # The Confirm Reports request is used to confirm the receipt of delivery
    # reports that were downloaded from the gateway. Delivery reports that are
    # unconfirmed will be downloaded each time a Check Reports request is made.
    # When delivery reports are confirmed they are marked as sent and will not
    # be downloaded again. It is not possible for a user to confirm delivery
    # reports that do not belong to them. Delivery reports must be confirmed on
    # an individual basis. Delivery reports are specified by their receipt ID.
    # This receipt ID is the same receipt ID that the delivery report was
    # assigned in the Check Reports response. The receipt ID is specified by
    # the attribute receiptId. See Section 7.9 for details on the Check
    # Reports response.
    # @api public
    # @param [Array] the receipt IDs
    # @return [String] the XML
    def confirm_reports(receipt_ids)
      xml = build_xml('confirmReports')
      common_code_array_to_xml(xml, :reports, :report, 'receiptId', receipt_ids)
    end

    # The Delete Scheduled Messages request is used to request the unscheduling
    # of messages that have been submitted to the gateway but are still yet to
    # be sent. Only messages that were given a scheduled timestamp in the Send
    # Messages request can be unscheduled. Only messages sent from the given
    # account can be unscheduled. Messages submitted to the gateway via other
    # APIs may be deleted via this method.
    # Messages must be confirmed on an individual basis. Messages are specified
    # by their message ID. This message ID is the same message ID that was
    # specified in recipient uid attribute in the Send Messages request.
    # Messages with an unrecognised message ID will be ignored.
    def delete_scheduled_messages(uids)
      xml = build_xml('deleteScheduledMessages')
      common_code_array_to_xml(xml, :messages, :message, 'messageId', uids)
    end

    # The Send Messages request is used to send one or more SMS or voice
    # messages to one or more recipients. The MessageMedia Messaging Web
    # Service does not place a hard limit on the number of messages that may be
    # placed in a request but users should be aware that it may be more
    # efficient to split large batches of messages into multiple requests to
    # avoid timing out their internet connections. In general, provided the
    # user has a sufficient internet connection, batches of up to one thousand
    # messages should be fine. Batches larger than this should be split up into
    # multiple requests. The XML Interface allows two types of messages to be
    # sent: SMS and voice. SMS messages may only be sent to mobile devices;
    # voice messages, on the other hand, may be sent to landlines and mobile
    # devices. Voice messages will be read out to the recipient by a
    # text-to-speech software application. The list of messages in the Send
    # Messages request may consist of both SMS and voice messages types and
    # each message may have multiple recipients.
    # @param [Array] Array of message Hashes
    # @param [String] send mode. defaults to normal.
    # @example send_messages([
    #            {content: 'Hello world',
    #             format: 'SMS',
    #             sequenceNumber: 1,
    #             origin: 123,
    #             numbers: [{number: 456, uid: 1}]
    #             scheduled: '2014-12-25T15:30:00Z'
    #             delivery_report: true
    #             validity_period: 143
    #             tags: [{name: 'foo', value: 1}]
    #            }]
    #          )
    def send_messages(messages, send_mode = 'normal')
      xml = build_xml('sendMessages')
      Nokogiri::XML::Builder.with(xml.doc.at('requestBody')) do |body_xml|
        body_xml.messages(sendMode: send_mode) do
          messages.each do |message|
            build_message(body_xml, message)
          end
        end
      end
      xml.doc.root.to_xml
    end

    private

    # helper method for send_messages, builds xml for one message
    # @param [Nokogiri::XML::Builder] at the position where you want the message inserted
    # @param [Array] message array from send_messages
    # @return nothing
    def build_message(body_xml, message)
      body_xml.message(message_element_attributes(message)) do
        body_xml.origin message[:origin] if message[:origin]
        body_xml.recipients do
          if message[:numbers] && !message[:numbers].empty?
            message[:numbers].each do |recipient|
              if recipient[:uid]
                body_xml.recipient recipient[:number], uid: recipient[:uid]
              else
                body_xml.recipient recipient[:number]
              end
            end
          end
        end
        build_optional_message_elements(body_xml, message)
      end
    end

    # helper method for build_message, returns attributes for XML element message
    # @param [Array] message array from send_messages
    # @return [Hash] Hash of the attrbites for this message based on input array
    def message_element_attributes(message)
      format = message['format'] || 'SMS'
      attributes = { format: format }
      attributes[:sequenceNumber] = message[:sequence_number] if message[:sequence_number]
      attributes
    end

    # helper method for send_message, builds optional XML elements
    # @param [Nokogiri::XML::Builder] at the position where you want them inserted
    # @return nothing
    def build_optional_message_elements(body_xml, message)
      body_xml.deliveryReport message[:delivery_report] if message[:delivery_report]
      body_xml.validityPeriod message[:validity_period] if message[:validity_period]
      body_xml.scheduled message[:scheduled] if message[:scheduled]
      body_xml.content message[:content]
      if message[:tags] && !message[:tags].empty?
        body_xml.tags do
          message[:tags].each do |tag|
            body_xml.tag tag[:value], name: tag[:name]
          end
        end
      end
      body_xml
    end

    # Common code for the element recipients used by (un)block_numbers
    # @param numbers [Integer Array] the number to be unblocked
    #   if you want to use the UID functionality an Array of Hashes is expected
    # @example common_code_for_element_recipients([61410000001,61410000002],
    #   xml) OR
    #   common_code_for_element_recipients([{number: '61410000001', uid: '1'},
    #   {number: '61410000002', uid: '2'}], xml)
    # @return [String] the XML
    def common_code_for_element_recipients(numbers, xml)
      Nokogiri::XML::Builder.with(xml.doc.at('requestBody')) do |body_xml|
        body_xml.recipients do
          numbers.each do |number|
            if number.is_a? Hash
              body_xml.recipient(uid: number[:uid]) do
                body_xml.text number[:number]
              end
            else
              body_xml.recipient number
            end
          end
        end
      end
      xml.doc.root.to_xml
    end

    # common code for max_results, will add an xml element named after the
    # param element with the value of max_results if max_results is set/true
    # @api private
    # @param [Nokogiri::XML::Builder] the current state of the xml build
    # @param [Symbol] the name of the element
    # @param [Integer] the integer value to be set for that element
    # @return [String] the finished xml
    def common_code_for_max_results(xml, element, max_results)
      Nokogiri::XML::Builder.with(xml.doc.at('requestBody')) do |body_xml|
        body_xml.send element, max_results if max_results
      end
      xml.doc.root.to_xml
    end

    # common code that will split an array into xml child elements
    # @param [Nokogiri::XML::Builder] the current state of the xml build
    # @param [Symbol] the name of the mother element
    # @param [Symbol] the name used for all the child elements
    # @param [String] the name of attribute key
    # @param [Array] attribute values of the child elements
    # @return [String] the finished XML
    def common_code_array_to_xml(xml, element, child_element, key, objects)
      Nokogiri::XML::Builder.with(xml.doc.at('requestBody')) do |body_xml|
        body_xml.send element do
          objects.each do |object|
            body_xml.send child_element, key => object
          end
        end
      end
      xml.doc.root.to_xml
    end

    # add wrapper incl. authentication around the xml_body
    # @api private
    # @param [STRING] the name of the root element
    # @param [Boolean] should we add the requestBody element? defaults to true
    # @return [STRING] xml including wrapper and authentication
    def build_xml(root_name, add_request_body = true)
      xml = Nokogiri::XML::Builder.new
      password = @password
      username = @username

      xml.send(root_name, 'xmlns' => 'http://xml.m4u.com.au/2009') do
        xml.authentication do
          xml.userId username
          xml.password password
        end
        xml.requestBody if add_request_body
      end
      xml
    end
  end
end
