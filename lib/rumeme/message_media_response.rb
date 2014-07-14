# encoding: UTF-8

# @author Hartwig Brandl <code@hartwigbrandl.com>
module Rumeme
  # handles the responses from MessageMedia
  class MessageMediaResponse
    attr_reader :xml, :parsed

    # load xml data into the instance
    # @api public
    def initialize(data)
      # currently we only support access to xml objects
      fail "expected xml got #{data}" unless data && data.include?('<?xml ')
      # save it raw and in parsed form
      @xml = data
      @parsed = Rumeme::ParseXmlSmsInterface.parse(@xml)
    end

    # ensure that the parsed xml is valid / as we expect it to be
    # @api public
    # @return [Boolean] is the parsed xml the way we expect it to be?
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.valid_response?
    def valid_response?
      return true if @parsed.first[1][0]['result'].count > 0
      rescue
        # something in the Hash / Array above is not as expected
        return false
    end

    # Does the response indicate a success?
    # @api public
    # @return [Boolean] was the response a success
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.success?
    def success?
      return false unless valid_response?

      # did we receive any errors?
      return false if @parsed.first[1][0]['result'][0]['errors']

      # is the failed attribute set to something larger than zero?
      return false if result_attributes['failed'].to_i > 0

      true
    end

    # shortcut to access the parsed errors xml
    # @api public
    # @return [Array] Array of all the erros (if any)
    # @example @example meme = MessageMediaResponse(xml_response)
    #   meme.errors
    def errors
      return [] unless valid_response?

      @parsed.first[1][0]['result'][0]['errors'] || []
    end

    def result_attributes
      return [] unless valid_response?
      @parsed.first[1][0]['result'][0]['attributes'] || {}
    end
  end
end
