require 'spec_helper'

describe Rumeme::BuildXmlSmsInterface do

  before(:all) do
    Rumeme.configuration = Rumeme::Configuration.new
    Rumeme.configuration.username = 'invalid_username'
    Rumeme.configuration.password = 'test'
  end

  it 'builds a correct BlockNumbersRequest' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    numbers = %w(123 456)
    expected_xml = '<blockNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <recipients>
      <recipient>123</recipient>
      <recipient>456</recipient>
    </recipients>
  </requestBody>
</blockNumbers>'
    expect(build_xml_sms_interface.block_numbers(numbers)).to eq expected_xml
  end

  it 'builds a correct BlockNumbersRequest with UIDs' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    numbers = [{ number: '123', uid: 1 }, { number: '456', uid: 2 }]
    expected_xml = '<blockNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <recipients>
      <recipient uid="1">123</recipient>
      <recipient uid="2">456</recipient>
    </recipients>
  </requestBody>
</blockNumbers>'
    expect(build_xml_sms_interface.block_numbers(numbers)).to eq expected_xml
  end

  it 'builds a correct UnblockNumbersRequest' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    numbers = %w(123 456)
    expected_xml = '<unblockNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <recipients>
      <recipient>123</recipient>
      <recipient>456</recipient>
    </recipients>
  </requestBody>
</unblockNumbers>'
    expect(build_xml_sms_interface.unblock_numbers(numbers)).to eq expected_xml
  end

  it 'builds a correct UnblockNumbersRequest with UIDs' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    numbers = [{ number: '123', uid: 1 }, { number: '456', uid: 2 }]
    expected_xml = '<unblockNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <recipients>
      <recipient uid="1">123</recipient>
      <recipient uid="2">456</recipient>
    </recipients>
  </requestBody>
</unblockNumbers>'
    expect(build_xml_sms_interface.unblock_numbers(numbers)).to eq expected_xml
  end

  it 'builds a correct GetBlockedNumbersRequest' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<getBlockedNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody/>
</getBlockedNumbers>'
    expect(build_xml_sms_interface.get_blocked_numbers).to eq expected_xml
  end

  it 'builds a correct GetBlockedNumbersRequest with limited results' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<getBlockedNumbers xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <maximumRecipients>50</maximumRecipients>
  </requestBody>
</getBlockedNumbers>'
    expect(build_xml_sms_interface.get_blocked_numbers(50)).to eq expected_xml
  end

  it 'builds a correct CheckUser request' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<checkUser xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
</checkUser>'
    expect(build_xml_sms_interface.check_user).to eq expected_xml
  end

  it 'builds a correct ConfirmReplies request' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<confirmReplies xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <replies>
      <reply receiptId="1"/>
      <reply receiptId="2"/>
      <reply receiptId="3"/>
    </replies>
  </requestBody>
</confirmReplies>'
    expect(build_xml_sms_interface.confirm_replies([1, 2, 3])).to eq expected_xml
  end

  it 'builds a correct ConfirmReports request' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expect_xml = '<confirmReports xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <reports>
      <report receiptId="1"/>
      <report receiptId="2"/>
      <report receiptId="3"/>
    </reports>
  </requestBody>
</confirmReports>'
    expect(build_xml_sms_interface.confirm_reports([1, 2, 3])).to eq expect_xml
  end

  it 'builds a correct DeleteScheduledMessages request' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<deleteScheduledMessages xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <messages>
      <message messageId="1"/>
      <message messageId="2"/>
      <message messageId="3"/>
    </messages>
  </requestBody>
</deleteScheduledMessages>'
    expect(build_xml_sms_interface.delete_scheduled_messages([1, 2, 3])
      ).to eq expected_xml
  end

  it 'builds a correct SendMessage request' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    build_xml = build_xml_sms_interface.send_messages([{ content: 'Hello world',
                format: 'SMS',
                sequence_number: '1',
                origin: 123,
                numbers: [{number: 456, uid: 1}, {number: 789, uid: 2}],
                scheduled: '2014-12-25T15:30:00Z',
                delivery_report: true,
                validity_period: 143,
                tags: [{name: 'foo', value: 1}, {name: 'bar', value: 2}]
               }]
             )
    expected_xml = '<sendMessages xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <messages sendMode="normal">
      <message format="SMS" sequenceNumber="1">
        <origin>123</origin>
        <recipients>
          <recipient uid="1">456</recipient>
          <recipient uid="2">789</recipient>
        </recipients>
        <deliveryReport>true</deliveryReport>
        <validityPeriod>143</validityPeriod>
        <scheduled>2014-12-25T15:30:00Z</scheduled>
        <content>Hello world</content>
        <tags>
          <tag name="foo">1</tag>
          <tag name="bar">2</tag>
        </tags>
      </message>
    </messages>
  </requestBody>
</sendMessages>'
    expect(build_xml).to eq expected_xml
  end

  it 'builds a correct SendMessage request without tags' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    build_xml = build_xml_sms_interface.send_messages([{ content: 'Hello world',
                format: 'SMS',
                sequence_number: '1',
                origin: 123,
                numbers: [{number: 456, uid: 1}, {number: 789, uid: 2}],
                scheduled: '2014-12-25T15:30:00Z',
                delivery_report: true,
                validity_period: 143,
               }]
             )
    expected_xml = '<sendMessages xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <messages sendMode="normal">
      <message format="SMS" sequenceNumber="1">
        <origin>123</origin>
        <recipients>
          <recipient uid="1">456</recipient>
          <recipient uid="2">789</recipient>
        </recipients>
        <deliveryReport>true</deliveryReport>
        <validityPeriod>143</validityPeriod>
        <scheduled>2014-12-25T15:30:00Z</scheduled>
        <content>Hello world</content>
      </message>
    </messages>
  </requestBody>
</sendMessages>'
    expect(build_xml).to eq expected_xml
  end

  it 'builds a correct SendMessage request without optional arguments' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    build_xml = build_xml_sms_interface.send_messages([{ content: 'Hello world',
                format: 'SMS',
                numbers: [{number: 456}, {number: 789}],
               }]
             )
    expected_xml = '<sendMessages xmlns="http://xml.m4u.com.au/2009">
  <authentication>
    <userId>invalid_username</userId>
    <password>test</password>
  </authentication>
  <requestBody>
    <messages sendMode="normal">
      <message format="SMS">
        <recipients>
          <recipient>456</recipient>
          <recipient>789</recipient>
        </recipients>
        <content>Hello world</content>
      </message>
    </messages>
  </requestBody>
</sendMessages>'
    expect(build_xml).to eq expected_xml
  end
end
