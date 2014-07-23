module Rumeme
  # handles the responses from MessageMedia
  class MessageMediaResponse
    attr_reader :xml, :parsed, :result

    # load xml data into the instance
    # @api public
    def initialize(data)
      # save it raw and in parsed form
      @xml = data
      @parsed = Rumeme::XmlParser.parse(@xml)
      begin
        if @parsed['faultResponse']
          @result = { 'errors' => @parsed['faultResponse'] }
        else
          @result = @parsed.first[1][0]['result'][0] || {}
        end
      rescue
        raise "The provided XML was not formatted as expected. xml=#{data}"
      end
    end

    # Does the response indicate a success?
    # @api public
    # @return [Boolean] was the response a success
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.success?
    def success?
      # did we receive any errors?
      return false if @result['errors']

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
      @result['errors'] || []
    end

    def result_attributes
      @result['attributes'] || {}
    end

    # reports returned by MessageMedia
    # @api public
    # @return [Array] Array of all the reports (if any)
    # example meme = MessageMediaResponse(xml_response)
    #   meme.reports
    def reports
      @result['reports'] || []
    end

    def account_details
      @result['accountDetails'] || []
    end

    # how many replies where confirmed (confirmReplyResponse)
    # @api public
    # @return [Integer] Number of confirmed
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.confirmed
    def confirmed
      result_attributes['confirmed'].to_i
    end

    # easy access to the result attribute unscheduled
    # @api public
    # @return [Integer] number of unscheduled messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.unscheduled
    def unscheduled
      result_attributes['unscheduled'].to_i
    end

    # easy access to the result attribute sent
    # @api public
    # @return [Integer] number of sent messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.sent
    def sent
      result_attributes['sent'].to_i
    end

    # easy access to the result attribute scheduled
    # @api public
    # @return [Integer] number of scheduled messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.scheduled
    def scheduled
      result_attributes['scheduled'].to_i
    end

    # easy access to the result attribute failed
    # @api public
    # @return [Integer] number of failed messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.failed
    def failed
      result_attributes['failed'].to_i
    end

    # easy access to the result attribute returned
    # @api public
    # @return [Integer] number of returned messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.returned
    def returned
      result_attributes['returned'].to_i
    end

    # easy access to the result attribute remaining
    # @api public
    # @return [Integer] number of remaining messages
    # @example meme = MessageMediaResponse(xml_response)
    #   meme.remaining
    def remaining
      result_attributes['remaining'].to_i
    end
  end
end
