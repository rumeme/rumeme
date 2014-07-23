require 'net/http'
require 'net/https'

module Rumeme
  # communicate with server(s) of MessageMedia
  class MessageMedia
    class << self
      # open secure or unsecure connection to message media
      def open_server_connection(server)
        port, use_ssl = @secure ? [443, true] : [80, false]

        http_connection = Net::HTTP.new(server, port)
        http_connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http_connection.use_ssl = use_ssl
        http_connection
      end

      def post_plain_text(text_buffer)
        http_connection = open_server_connection(Rumeme::Configuration::PLAIN_TEXT_SERVERS[0])

        headers = { 'Content-Length' => text_buffer.length.to_s }

        path = '/'

        resp = http_connection.post(path, text_buffer, headers)
        data = resp.body

        fail BadServerResponse, 'http response code != 200' unless resp.code.to_i == 200

        if data =~ %r{^.+<TITLE>(.+)</TITLE>.+<BODY>(.+)</BODY>.+}m
          parsed_title, parsed_body = $1, $2
        else
          fail BadServerResponse, 'not html'
        end

        fail BadServerResponse, 'bad title' unless parsed_title == 'M4U SMSMASTER'

        parsed_body.strip
      end

      # post method for the XML interface
      # @api public
      # @example Rumeme::MessageMedia.post_xml(the_xml)
      def post_xml(xml)
        if testing
          data = mock_response
        else
          http_connection = open_server_connection(Rumeme::Configuration::XML_SERVERS[0])
          path = '/'
          resp = http_connection.post(path, 'XMLDATA=' + xml)
          data = resp.body
        end
        Rumeme::MessageMediaResponse.new(data)
      end

      # know if we are only testing
      # @api private
      def testing
        Rumeme.configuration.testing
      end

      # mock a response (usefull for testing)
      # @api private
      def mock_response
        Rumeme.configuration.mock_response
      end
    end

    private_class_method :testing, :mock_response
  end
end
