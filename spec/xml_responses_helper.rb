# encoding: UTF-8

# HELPER constants

CORRECT_NUMBER = 61_410_000_001
CORRECT_NUMBER_2 = 61_410_000_002
FAILING_NUMBER = 1_555_800_800

# XML mock responses

INVALID_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <invalid />
</blockNumbersResponse>'

FAILED_ATTRIBUTE_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result blocked="1" failed="1"/>
</blockNumbersResponse>'

NO_ATTRIBUTES_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result/>
</blockNumbersResponse>'

SUCCEEDING_BLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result blocked="1" failed="0"/>
</blockNumbersResponse>'

SUCCEEDING_MULTIPLE_BLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result blocked="2" failed="0"/>
</blockNumbersResponse>'

FAILING_BLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<blockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result blocked="0" failed="1">
    <errors>
      <error code="invalidRecipient" sequenceNumber="0">
        <recipients>
          <recipient uid="0">' + FAILING_NUMBER.to_s + '</recipient>
        </recipients>
      </error>
    </errors>
  </result>
</blockNumbersResponse>'

SUCCEEDING_GET_BLOCKED_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<getBlockedNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result found="1" returned="1">
    <recipients>
      <recipient uid="0">' + CORRECT_NUMBER.to_s + '</recipient>
    </recipients>
  </result>
</getBlockedNumbersResponse>'

EMPTY_GET_BLOCKED_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<getBlockedNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result found="0" returned="0"/>
</getBlockedNumbersResponse>'

LIMITED_GET_BLOCKED_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<getBlockedNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result found="2" returned="1">
    <recipients>
      <recipient uid="0">61410000001</recipient>
    </recipients>
  </result>
</getBlockedNumbersResponse>'

SUCCEEDING_UNBLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<unblockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result unblocked="1" failed="0"/>
</unblockNumbersResponse>'

SUCCEEDING_MULTIPLE_UNBLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<unblockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result unblocked="2" failed="0"/>
</unblockNumbersResponse>'

FAILING_UNBLOCK_NUMBERS_RESPONSE =
'<?xml version="1.0" encoding="utf-8"?>
<unblockNumbersResponse xmlns="http://xml.m4u.com.au/2009">
  <result unblocked="0" failed="1">
    <errors>
      <error code="invalidRecipient" sequenceNumber="0">
        <recipients>
          <recipient uid="0">' + FAILING_NUMBER.to_s + '</recipient>
        </recipients>
      </error>
    </errors>
  </result>
</unblockNumbersResponse>'
