# encoding: UTF-8

require 'spec_helper'
require 'xml_responses_helper'

describe Rumeme::SmsInterface do

  pending "add some tests for plain text methods to #{__FILE__}"

  before(:all) do
    Rumeme.configuration = Rumeme::Configuration.new
    # set this to false to use the live servers of MessageMedia
    Rumeme.configuration.testing = true
    # if you're using the live servers, set these two env variables
    Rumeme.configuration.username = ENV['MEME_USERNAME']
    Rumeme.configuration.password = ENV['MEME_PASSWORD']

    if Rumeme.configuration.testing
      puts '
# mocking responses from message media
# no interaction with their server will take place'
    else
      puts '# using live servers of MessageMedia'
      if ENV['MEME_USERNAME'].nil? && ENV['MEME_PASSWORD'].nil?
        fail 'set environment variables MEME_USERNAME and MEME_PASSWORD'
      end
    end

  end

  before(:each) do
    sms_interface = Rumeme::SmsInterface.new
    Rumeme.configuration.mock_response = SUCCEEDING_UNBLOCK_NUMBERS_RESPONSE
    sms_interface.unblock_numbers([CORRECT_NUMBER, CORRECT_NUMBER_2])
    Rumeme.configuration.mock_response = nil
  end

  it 'tests a succeeding blockNumbersRequest' do
    Rumeme.configuration.mock_response = SUCCEEDING_BLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.block_numbers([CORRECT_NUMBER])
    expect(response.success?).to eq true
    expect(response.result_attributes['blocked']).to eq '1'
    expect(response.result_attributes['failed']).to eq '0'
  end

  it 'tests a succeeding blockNumbersRequest with multiple numbers' do
    Rumeme.configuration.mock_response =
      SUCCEEDING_MULTIPLE_BLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.block_numbers([CORRECT_NUMBER, CORRECT_NUMBER_2])
    expect(response.success?).to eq true
    expect(response.result_attributes['blocked']).to eq '2'
    expect(response.result_attributes['failed']).to eq '0'
  end

  it 'tests a succeeding blockNumbersRequest with UID' do
    Rumeme.configuration.mock_response = SUCCEEDING_BLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.block_numbers([
      { number: CORRECT_NUMBER, uid: '100' }
    ])
    expect(response.success?).to eq true
    expect(response.result_attributes['blocked']).to eq '1'
    expect(response.result_attributes['failed']).to eq '0'
  end

  it 'tests a succeeding blockNumbersRequest with multiple numbers and UID' do
    Rumeme.configuration.mock_response =
      SUCCEEDING_MULTIPLE_BLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.block_numbers([
      { number: CORRECT_NUMBER, uid: '100' },
      { number: CORRECT_NUMBER_2, uid: '101' }])
    expect(response.success?).to eq true
    expect(response.result_attributes['blocked']).to eq '2'
    expect(response.result_attributes['failed']).to eq '0'
  end

  it 'tests a failing blockNumbersRequest' do
    Rumeme.configuration.mock_response = FAILING_BLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.block_numbers([FAILING_NUMBER])
    expect(response.success?).to eq false
    expect(response.result_attributes['blocked']).to eq '0'
    expect(response.result_attributes['failed']).to eq '1'
  end

  it 'tests a succeeding getBlockedNumbersRequest', focus: true do
    Rumeme.configuration.mock_response = SUCCEEDING_GET_BLOCKED_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    sms_interface.block_numbers([CORRECT_NUMBER])
    response = sms_interface.get_blocked_numbers
    expect(response.success?).to eq true
    expect(response.result_attributes['found']).to eq '1'
    expect(response.result_attributes['returned']).to eq '1'
    expect(response.errors).to eq []
  end

  it 'tests an empty getBlockedNumbersRequest' do
    Rumeme.configuration.mock_response = EMPTY_GET_BLOCKED_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.get_blocked_numbers
    expect(response.success?).to eq true
    expect(response.result_attributes['found']).to eq '0'
    expect(response.result_attributes['returned']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a limited getBlockedNumbersRequest' do
    Rumeme.configuration.mock_response = LIMITED_GET_BLOCKED_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    sms_interface.block_numbers([CORRECT_NUMBER])
    sms_interface.block_numbers([CORRECT_NUMBER_2])
    response = sms_interface.get_blocked_numbers(1)
    expect(response.success?).to eq true
    expect(response.result_attributes['found']).to eq '2'
    expect(response.result_attributes['returned']).to eq '1'
    expect(response.errors).to eq []
  end

  it 'tests a succeeding unblockNumbersRequest' do
    Rumeme.configuration.mock_response = SUCCEEDING_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([CORRECT_NUMBER])
    expect(response.success?).to eq true
    expect(response.result_attributes['unblocked']).to eq '1'
    expect(response.result_attributes['failed']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a succeeding unblockNumbersRequest with multiple numbers' do
    Rumeme.configuration.mock_response =
      SUCCEEDING_MULTIPLE_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([CORRECT_NUMBER, CORRECT_NUMBER_2])
    expect(response.success?).to eq true
    expect(response.result_attributes['unblocked']).to eq '2'
    expect(response.result_attributes['failed']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a succeeding unblockNumbersRequest with uid' do
    Rumeme.configuration.mock_response = SUCCEEDING_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([
      { number: CORRECT_NUMBER, uid: '1' }
    ])
    expect(response.success?).to eq true
    expect(response.result_attributes['unblocked']).to eq '1'
    expect(response.result_attributes['failed']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a succeeding ublockNumbersRequest with multiple numbers and uids' do
    Rumeme.configuration.mock_response =
      SUCCEEDING_MULTIPLE_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([
      { number: CORRECT_NUMBER },
      { number: CORRECT_NUMBER_2 }])
    expect(response.success?).to eq true
    expect(response.result_attributes['unblocked']).to eq '2'
    expect(response.result_attributes['failed']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a succeeding ublockNumbersRequest multiple numbers with uids' do
    Rumeme.configuration.mock_response =
      SUCCEEDING_MULTIPLE_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([
      { number: CORRECT_NUMBER, uid: '1' },
      { number: CORRECT_NUMBER_2, uid: '2' }])
    expect(response.success?).to eq true
    expect(response.result_attributes['unblocked']).to eq '2'
    expect(response.result_attributes['failed']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a failing unblockNumbersRequest', focus: true do
    Rumeme.configuration.mock_response = FAILING_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([FAILING_NUMBER])
    expect(response.success?).to eq false
    expect(response.result_attributes['unblocked']).to eq '0'
    expect(response.result_attributes['failed']).to eq '1'
    expect(response.errors.count).to be > 0
  end
end
