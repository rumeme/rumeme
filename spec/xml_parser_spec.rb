require 'spec_helper'
require 'xml_responses_helper'

describe Rumeme::XmlParser do

  it 'successfully parses a valid xml file' do
    xml = SUCCEEDING_GET_BLOCKED_NUMBERS_RESPONSE
    parsed = Rumeme::XmlParser.parse(xml)
    expected_hash = { 'getBlockedNumbersResponse' =>
      [
        { 'result' =>
          [
            { 'attributes' =>
              { 'found' => '1', 'returned' => '1' },
              'recipients' =>
              [
                { 'recipient' =>
                  [
                    { 'attributes' =>
                      { 'uid' => '0' },
                      'text' => '61410000001'
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
    expect(parsed).to eq expected_hash
  end
end
