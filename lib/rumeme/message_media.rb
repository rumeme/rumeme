# encoding: UTF-8

require 'net/http'
require 'net/https'

module Rumeme
  # communicate with server(s) of MessageMedia
  class MessageMedia
    # open secure or unsecure connection to message media
    def self.open_server_connection(server)
      port, use_ssl = @secure ? [443, true] : [80, false]

      http_connection = Net::HTTP.new(server, port)
      http_connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http_connection.use_ssl = use_ssl
      http_connection
    end

    # plain text api post method
    def self.post_data_to_server(data)
      server_list = %w(smsmaster.m4u.com.au smsmaster1.m4u.com.au smsmaster2.m4u.com.au)

      http_connection = open_server_connection(server_list[0])

      headers = { 'Content-Length' => data.length.to_s }

      path = '/'

      resp = http_connection.post(path, data, headers)
      data = resp.body

      fail BadServerResponse, 'http response code != 200' unless resp.code.to_i == 200

      if data =~ %r{^.+<TITLE>(.+)</TITLE>.+<BODY>(.+)</BODY>.+}m
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
    def self.post_xml(xml)
      if testing
        data = mock_response
      else
        server_list = %w(xml.m4u.com.au)
        http_connection = open_server_connection(server_list[0])
        path = '/'
        resp = http_connection.post(path, 'XMLDATA=' + xml)
        data = resp.body
      end
      Rumeme::MessageMediaResponse.new(data)
    end

    # know if we are only testing
    # @api private
    # @author Hartwig Brandl <code@hartwigbrandl.com>
    def self.testing
      Rumeme.configuration.testing
    end

    # mock a response (usefull for testing)
    # @api private
    # @author Hartwig Brandl <code@hartwigbrandl.com>
    def self.mock_response
      Rumeme.configuration.mock_response
    end

    private_class_method :testing, :mock_response
  end
end
