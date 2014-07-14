# encoding: UTF-8

# Rumeme main module
module Rumeme
  # Build the XML for the XML API Interface
  # @author Hartwig Brandl <code@hartwigbrandl.com>
  class BuildXmlSmsInterface
    # load credentials from the configuration file
    def initialize
      Rumeme.configuration.tap do |config|
        @username = config.username
        @password = config.password
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
      block_numbers_body_xml = common_code_for_element_recipients(numbers)
      # add XML wrapper
      build_xml('blockNumbers', block_numbers_body_xml)
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
      unblock_numbers_body_xml = common_code_for_element_recipients(numbers)
      # add XML wrapper
      build_xml('unblockNumbers', unblock_numbers_body_xml)
    end

    # The Get Blocked Numbers request is used retrieve a list of numbers that
    # are currently blocked for the authenticated account.
    # @api public
    # @param [Integer] Maximum number of results (numbers) to be returned
    # @return [String] the XML
    def get_blocked_numbers(max_results = false)
      body_xml = ''
      if max_results
        body_xml << " <maximumRecipients>#{max_results}</maximumRecipients>"
      end
      build_xml('getBlockedNumbers', body_xml)
    end

    private

    # Common code for the element recipients used by (un)block_numbers
    def common_code_for_element_recipients(numbers)
      recipients_body_xml = '<recipients>'
      numbers.each do |number|
        # start the XML block
        recipients_body_xml << "\n    <recipient"
        # individual numbers and (optional) UIDs
        if number.is_a? Hash
          recipients_body_xml << " uid=\"#{number[:uid]}\""
          number = number[:number]
        end
        recipients_body_xml << ">#{number}</recipient>"
      end
      # close XML block
      recipients_body_xml << "\n  </recipients>"
    end

    # add wrapper incl. authentication around the xml_body
    # @api private
    # @param [STRING] the name of the root element
    # @param [STRING] xml to be included within <requestBody>
    # @return [STRING] xml including wrapper and authentication
    def build_xml(root_name, xml_body)
      "<#{root_name} xmlns=\"http://xml.m4u.com.au/2009\">
<authentication>
 <userId>#{@username}</userId>
 <password>#{@password}</password>
</authentication>
<requestBody>
 #{xml_body}
</requestBody>
</#{root_name}>
"
    end
  end
end
