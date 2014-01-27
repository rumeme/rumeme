require 'spec_helper'

describe Rumeme::SmsInterface, vcr: { cassette_name: 'm4u', match_requests_on: [:method, :uri, :body] } do
  before(:all) do
    Rumeme.configure do |config|
      config.username = 'USERNAME'
      config.password = 'SECRET'
      config.use_message_id = true
      config.secure = true
    end
  end

  subject(:sms_inteface) { Rumeme::SmsInterface.new }

  describe '#send_messages!' do
    it "doesn't raise exception when message has been sucessfully sent" do
      add_success_message
      expect { sms_inteface.send_messages! }.to_not raise_error
    end

    it 'raises exception when message hasnt been sent' do
      add_fail_message
      expect { sms_inteface.send_messages! }.to raise_error(Rumeme::SmsInterface::BadServerResponse, 'error during sending messages')
    end
  end

  describe '#send_messages' do
    it 'returns true when messages have been sucessfully sent' do
      add_success_message
      expect(sms_inteface.send_messages).to eq(true)
    end

    it 'returns false when messages delivery has been failed' do
      add_fail_message
      expect(sms_inteface.send_messages).to eq(false)
    end
  end

  describe '#clear_messages' do
    it 'clears messages from the list' do
      add_success_message
      add_success_message
      sms_inteface.clear_messages

      expect(sms_inteface.send_messages).to eq(true)
    end
  end

  # TODO: it returns when empty
  # TODO: it doesn't send any request

  describe '#confirm_replies_received' do
    it 'sends confirm request' do
      response_message, response_code = sms_inteface.confirm_replies_received
      expect(response_code).to eq(100)
    end
  end

  def add_success_message
    sms_inteface.add_message phone_number: '11234567', message: 'ok message text'
  end

  def add_fail_message
    sms_inteface.add_message phone_number: '11234567', message: 'fail message text'
  end
end
