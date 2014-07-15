# encoding: UTF-8

require 'nokogiri'

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
      Nokogiri::XML::Builder.with(xml.doc.at('requestBody')) do |body_xml|
        body_xml.maximumRecipients max_results if max_results
      end
      xml.doc.root.to_xml
    end

    private

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

    # add wrapper incl. authentication around the xml_body
    # @api private
    # @param [STRING] the name of the root element
    # @param [STRING] xml to be included within <requestBody>
    # @return [STRING] xml including wrapper and authentication
    def build_xml(root_name)
      xml = Nokogiri::XML::Builder.new
      password = @password
      username = @username

      xml.send(root_name, 'xmlns' => 'http://xml.m4u.com.au/2009') do
        xml.authentication do
          xml.userId username
          xml.password password
        end
        xml.requestBody
      end
      xml
    end
  end
end
