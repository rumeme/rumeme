# encoding: UTF-8

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
</blockNumbers>
'
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
</blockNumbers>
'
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
</unblockNumbers>
'
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
</unblockNumbers>
'
    expect(build_xml_sms_interface.unblock_numbers(numbers)).to eq expected_xml
  end

  it 'builds a correct GetBlockedNumbersRequest' do
    build_xml_sms_interface = Rumeme::BuildXmlSmsInterface.new
    expected_xml = '<getBlockedNumbers xmlns="http://xml.m4u.com.au/2009">
<authentication>
 <userId>invalid_username</userId>
 <password>test</password>
</authentication>
<requestBody>
' + ' ' + '
</requestBody>
</getBlockedNumbers>
'
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
</getBlockedNumbers>
'
    expect(build_xml_sms_interface.get_blocked_numbers(50)).to eq expected_xml
  end
end
