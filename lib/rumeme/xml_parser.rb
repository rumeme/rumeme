# encoding: UTF-8

# Rumeme main module
module Rumeme
  # Build the XML for the XML API Interface
  # @author Hartwig Brandl <code@hartwigbrandl.com>
  class XmlParser
    require 'nokogiri'

    class << self
      # parse an xml response from message media
      # @api private
      # @param [String] the xml response as a string
      # @return [Hash] xml parsed into an Hash
      # @example parse(xml_response)
      def parse(xml)
        # currently we only support access to xml objects
        fail "expected xml got #{xml}" unless xml && xml.include?('<?xml ')

        doc = Nokogiri::XML(xml)
        parser_helper(doc)
      end

      # recursive function to parse the whole xml tree
      # @api private
      # @param [Nokogiri::XML::Document OR Nokogiri::XML::Element] parsed xml
      # @return [Hash] parsed xml document as a hash
      def parser_helper(doc)
        # if you pass me a Nokogiri::XML::Element I'll add its attributes
        result = parse_attributes_and_text({}, doc)

        # loop through all children
        doc.children.each do |element|
          # we don't need Nokogiri::XML::Text elements
          next if element.is_a? Nokogiri::XML::Text

          # recursive call to parse all children
          parsed_element = parser_helper(element)

          # add attributes and text
          parsed_element = parse_attributes_and_text(parsed_element, element)

          # save it to the result hash
          result[element.name] ||= []
          result[element.name].push(parsed_element)
        end
        result
      end

      # write attributes and text of a Nokogiri::XML::Element to the passed hash
      # @api private
      # @param [Hash] Hash to be written to
      # @param [Nokogiri::XML::Element] xml to be analysed
      # @return [Hash] Hash with added information
      def parse_attributes_and_text(result_hash, element)
        # I only do stuff if you pass my a Nokogiri::XML::Element
        return result_hash unless element.is_a? Nokogiri::XML::Element

        # parse attributes
        if element.attributes.count > 0
          result_hash['attributes'] = {}
          element.attributes.each do |attribute|
            result_hash['attributes'][attribute[1].name] = attribute[1].value
          end
        end

        # text with a newline will be combined texts of children
        result_hash['text'] = element.text unless element.text.include?("\n")

        result_hash
      end
    end

    private_class_method :parser_helper, :parse_attributes_and_text
  end
end
