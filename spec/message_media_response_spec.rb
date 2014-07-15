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
    response = Rumeme::MessageMediaResponse.new(SUCCEEDING_BLOCK_NUMBERS_RESPONSE)
    expect(response.success?).to eq true
    expect(response.result_attributes.count).to eq 2
  end
end
