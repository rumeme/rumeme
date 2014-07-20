require 'spec_helper'
require 'xml_responses_helper'

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

  # describe '#send_messages!' do
  #   it "doesn't raise exception when message has been sucessfully sent" do
  #     add_success_message
  #     expect { sms_inteface.send_messages! }.to_not raise_error
  #   end

  #   it 'raises exception when message hasnt been sent' do
  #     add_fail_message
  #     expect { sms_inteface.send_messages! }.to raise_error(Rumeme::SmsInterface::BadServerResponse, 'error during sending messages')
  #   end
  # end

  # describe '#send_messages' do
  #   it 'returns true when messages have been sucessfully sent' do
  #     add_success_message
  #     expect(sms_inteface.send_messages).to eq(true)
  #   end

  #   it 'returns false when messages delivery has been failed' do
  #     add_fail_message
  #     expect(sms_inteface.send_messages).to eq(false)
  #   end
  # end

  # describe '#clear_messages' do
  #   it 'clears messages from the list' do
  #     add_success_message
  #     add_success_message
  #     sms_inteface.clear_messages

  #     expect(sms_inteface.send_messages).to eq(true)
  #   end
  # end

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

  it 'tests an empty getBlockedNumbersRequest' do
    Rumeme.configuration.mock_response = EMPTY_GET_BLOCKED_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    sms_interface.unblock_numbers([CORRECT_NUMBER, CORRECT_NUMBER_2])
    # caching issues (by MessageMedia)
    sleep(1.0)
    response = sms_interface.get_blocked_numbers
    expect(response.success?).to eq true
    expect(response.result_attributes['found']).to eq '0'
    expect(response.result_attributes['returned']).to eq '0'
    expect(response.errors).to eq []
  end

  it 'tests a limited getBlockedNumbersRequest' do
    Rumeme.configuration.mock_response = LIMITED_GET_BLOCKED_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    sms_interface.block_numbers([CORRECT_NUMBER, CORRECT_NUMBER_2])
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

  it 'tests a failing unblockNumbersRequest' do
    Rumeme.configuration.mock_response = FAILING_UNBLOCK_NUMBERS_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.unblock_numbers([FAILING_NUMBER])
    expect(response.success?).to eq false
    expect(response.result_attributes['unblocked']).to eq '0'
    expect(response.result_attributes['failed']).to eq '1'
    expect(response.errors.count).to be > 0
  end

  it 'tests a checkUser request' do
    Rumeme.configuration.mock_response = CHECK_USER_RESPONSE
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.check_user
    expect(response.account_details).to eq [{
      'attributes' =>
        { 'type' => 'daily',
          'creditLimit' => '1089',
          'creditRemaining' => '1089' } }]
  end

  it 'tests a succeedig confirmReplies request' do
    sms_interface = Rumeme::SmsInterface.new
    # confirming invalid replies, nothing to confirm for MessageMedia
    response = sms_interface.confirm_replies([1, 2 , 3 , 4 , 5])
    expect(response.confirmed).to eq 0
  end

  it 'tests a send Message request and delivery report check & confirm' do
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.xml_send_messages([{ content: 'Hello world',
                format: 'SMS',
                numbers: [{number: CORRECT_NUMBER}, {number: CORRECT_NUMBER_2}],
                deliveryReport: true,
               }]
             )
    expect(response.success?).to eq true
    expect(response.sent).to eq 2
    expect(response.scheduled).to eq 0
    expect(response.failed).to eq 0
    # sms messages won't be delivered that fast
    response = sms_interface.check_reports
    expect(response.success?).to eq true
    expect(response.returned).to eq 0
    expect(response.remaining).to eq 0
    # confirming invalid report is => nothing to confirm for MessageMedia
    response = sms_interface.confirm_reports([123, 456])
    expect(response.confirmed).to eq 0
  end

   it 'tests a scheduled send Message request & deleteScheduledMessages request' do
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.xml_send_messages([{ content: 'Hello world',
                format: 'SMS',
                numbers: [{number: CORRECT_NUMBER, uid: 12345}, {number: CORRECT_NUMBER_2, uid: 6789}],
                scheduled: "#{Time.now.year}-12-31T23:30:00Z",
               }]
             )
    expect(response.success?).to eq true
    expect(response.sent).to eq 0
    expect(response.scheduled).to eq 2
    expect(response.failed).to eq 0

    # unschedule
    response = sms_interface.delete_scheduled_messages([12345, 6789])
    expect(response.success?).to eq true
    expect(response.unscheduled).to eq 2
  end

  it 'tests a send Message request and delivery report' do
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.xml_send_messages([{ content: 'Hello world',
                format: 'SMS',
                numbers: [{number: CORRECT_NUMBER}, {number: CORRECT_NUMBER_2}],
                deliveryReport: true,
               }]
             )
    expect(response.success?).to eq true
  
  end

  it 'tests the full send message interface' do
    sms_interface = Rumeme::SmsInterface.new
    response = sms_interface.xml_send_messages([{content: 'Hello world',
                  format: 'SMS',
                  sequenceNumber: 1,
                  origin: 123,
                  numbers: [{number: CORRECT_NUMBER, uid: 1}],
                  scheduled: '2014-12-25T15:30:00Z',
                  delivery_report: true,
                  validity_period: 143}])
    expect(response.success?).to eq true
  end
end
