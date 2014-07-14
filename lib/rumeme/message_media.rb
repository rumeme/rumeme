# encoding: UTF-8

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

      # plain text api post method
      def post_data_to_server(data)
        http_connection = open_server_connection(Rumeme::Configuration::PLAIN_TEXT_SERVERS[0])

        headers = { 'Content-Length' => data.length.to_s }

        path = '/'

        resp = http_connection.post(path, data, headers)

        fail BadServerResponse, 'http response code != 200' unless resp.code.to_i == 200

        if resp.body =~ %r{^.+<TITLE>(.+)</TITLE>.+<BODY>(.+)</BODY>.+}m
          parsed_title, parsed_body = $1, $2

          fail BadServerResponse, 'bad title' unless parsed_title == 'M4U SMSMASTER'
          return parsed_title, parsed_body
        else
          fail BadServerResponse, 'not html or xml'
        end
      end

      # post method for the XML interface
      # @api public
      # @author Hartwig Brandl <code@hartwigbrandl.com>
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
      # @author Hartwig Brandl <code@hartwigbrandl.com>
      def testing
        Rumeme.configuration.testing
      end

      # mock a response (usefull for testing)
      # @api private
      # @author Hartwig Brandl <code@hartwigbrandl.com>
      def mock_response
        Rumeme.configuration.mock_response
      end
    end

    private_class_method :testing, :mock_response
  end
end
