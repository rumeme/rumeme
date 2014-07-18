# encoding: UTF-8

require 'spec_helper'
require 'xml_responses_helper'

describe Rumeme::MessageMediaResponse do

  it 'tests for an invalid valid response' do
    expect { Rumeme::MessageMediaResponse.new(INVALID_RESPONSE) }.to raise_error
  end

  it 'tests for a failed success, valid response with errors' do
    response = Rumeme::MessageMediaResponse.new(FAILING_BLOCK_NUMBERS_RESPONSE)
    expect(response.success?).to eq false
  end

  it 'tests for a failed success, valid resp., no errors, failed attribute' do
    response = Rumeme::MessageMediaResponse.new(FAILED_ATTRIBUTE_RESPONSE)
    expect(response.success?).to eq false
  end

  it 'ensure we get the errors array' do
    response = Rumeme::MessageMediaResponse.new(FAILING_BLOCK_NUMBERS_RESPONSE)
    expect(response.errors.count).to be > 0
  end

  it 'ensure we get an empty errors array if there are none' do
    response = Rumeme::MessageMediaResponse.new(SUCCEEDING_BLOCK_NUMBERS_RESPONSE)
    expect(response.errors.count).to eq 0
  end

  it 'ensures we get an empty results_attributes array if there are none' do
    response = Rumeme::MessageMediaResponse.new(NO_ATTRIBUTES_RESPONSE)
    expect(response.success?).to eq true
    expect(response.result_attributes.count).to eq 0
  end

  it 'ensures we get the results attributes' do
    response = Rumeme::MessageMediaResponse.new(CONFIRM_REPLIES_RESPONSE)
    expect(response.success?).to eq true
    expect(response.result_attributes.count).to eq 1
  end

  it 'ensures confirm works on wrong responses' do
    response = Rumeme::MessageMediaResponse.new(SUCCEEDING_BLOCK_NUMBERS_RESPONSE)
    expect(response.success?).to eq true
    expect(response.confirmed).to eq 0
  end

  it 'ensures confirm works as expected on correct responses' do
    response = Rumeme::MessageMediaResponse.new(CONFIRM_REPLIES_RESPONSE)
    expect(response.success?).to eq true
    expect(response.confirmed).to eq 5
  end

  it 'ensures we get empty reports' do
    response = Rumeme::MessageMediaResponse.new(CHECK_EMPTY_REPORTS_RESPONSE)
    expect(response.success?).to eq true
    expect(response.reports.count).to eq 0
  end

  it 'ensures we get reports' do
    response = Rumeme::MessageMediaResponse.new(CHECK_REPORTS_RESPONSE)
    expect(response.success?).to eq true
    expect(response.reports[0]['report'].count).to eq 4
  end

  it 'ensures we get the account details', focus: true do
    response = Rumeme::MessageMediaResponse.new(CHECK_USER_RESPONSE)
    expect(response.success?).to eq true
    expect(response.account_details).to eq [{
      'attributes' =>
        { 'type' => 'daily',
          'creditLimit' => '1089',
          'creditRemaining' => '1089' }}]
  end

  it 'ensures calling unscheduled works' do
    response = Rumeme::MessageMediaResponse.new(DELETE_SCHEDULED_MESSAGES_RESPONSE)
    expect(response.unscheduled).to eq 3
  end

  it 'correctly handles a faultResponse' do
    response = Rumeme::MessageMediaResponse.new(FAULT_RESPONSE)
    expect(response.success?).to eq false
    expect(response.errors.count).to eq 1
  end
end
