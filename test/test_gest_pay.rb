# This file is part of RGestPay.
#
# RGestPay is a Ruby implementation of GestPayCryptHS the Java
# class for GestPay payments.
#
# RGestPay Copyright (C)2006 by Giovanni Intini <medlar@medlar.it>
# 
# RGestPay is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# RGestPay is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with RGestPay; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# Author: Giovanni Intini <medlar@medlar.it>

require '../lib/gest_pay'
require 'test/unit'

class TestGestPay < Test::Unit::TestCase
  def setup
    @t = GestPay::TransactionData.new
    @t[:currency] = 242
    @t[:amount] = 1
    @t[:shop_transaction_id] = 23434
    
    # Please use your shop login info
    # You can get test logins from www.easynolo.it
    @c = GestPay::CryptRequest.new("GESPAYxxxxx")
    
    # Please change this string to a "fresh" string to decrypt, the server won't decrypt
    # strings that get too old. This string is the result of a completed transaction.
    @encrypted_string = "703C404A28AA7E9F35CA9FD261889382FA76E535699F98E0C531537E41CDCD221115A745D39E6FC9EA95ED35E2670FDAEECEE84396340D81A942D8409B6AE9DF95B9B7E73CAB197221DA00B5F316F7A01CDF05B77D27F7B810F023B5C357094D973DAA791A416483E9D2F0ADBF9AA9AA56FF98ECA02257FE9CC4A410E4EE111F3051596011D818C9973DAA791A416483CAA61CD14DD098410C82BBE55075064E8B8AC03D06BA88A227AA73A72DBA0EDBBF89B63CEA4C501E10BCF46DD8158687ECC652B76875C514AB5284A0DC0A0A4A5F14E2D1250C7BA9BFED0B5970D5FE452B6D10C1AAB0664C6BC4D51F086686F5B6E030234BA4A8E854D005A518321BC51F61786A0F3028FAA066882F97F333EAB82596EAA95602385F102D0B418B9D88B6E98E6971E999B0A93349197AB89B18F3ADB462F51A68A8"
  end
  
  def test_transaction_data_fetch_nil_attribute
    @t[:really_strange_attribute] = 3
    assert_nil @t[:really_strange_attribute]
  end
  
  def test_transaction_data_to_str
    assert_not_nil @t.to_str
  end
  
  def test_transaction_data_ready_to_encrypt
    assert @t.ready_to_encrypt?
  end
  
  def test_transaction_data_encrypt_error_553
    @t[:amount] = nil
    t = GestPay::TransactionData.new(@t.encrypt_error)
    assert_equal 553, t[:error_code]
    assert_equal "amount not valid", t[:error_description]
  end
  
  def test_transaction_data_encrypt_error_551
    @t[:shop_transaction_id] = nil
    t = GestPay::TransactionData.new(@t.encrypt_error)
    assert_equal 551, t[:error_code]
    assert_equal "shop_transaction_id not valid", t[:error_description]
  end
  
  def test_transaction_data_no_encrypt_errors
    t = GestPay::TransactionData.new(@t.encrypt_error)
    assert_nil t[:error_code]
    assert_nil t[:error_description]
  end

  def test_transaction_data_create_from_string
    t = GestPay::TransactionData.new "PAY1_UICCODE=242*P1*PAY1_SHOPTRANSACTIONID=34314"
    assert_equal "242", t[:currency]
    assert_equal "34314", t[:shop_transaction_id]
  end
  
  def test_transaction_data_create_from_string_with_custom_info
    t = GestPay::TransactionData.new "PAY1_UICCODE=242*P1*PAY1_SHOPTRANSACTIONID=34314*P1*ENZO=34*P1*RENATO=ALFA"
    assert_equal "*P1*ENZO=34*P1*RENATO=ALFA", t[:custom_info]
  end
  
  def test_transaction_data_resets_error_code
    t = GestPay::TransactionData.new "PAY1_UICCODE=242*P1*PAY1_SHOPTRANSACTIONID=34314*P1*PAY1_ERRORCODE=0"
    assert_nil t[:error_code]
  end

  def test_crypt_request_crypt_url
    assert_equal "?a=GESPAY35928&b=mamma&c=2.0", @c.send(:crypt_url, "mamma")
  end
  
  def test_crypt_request_encrypt_url
    assert_equal "/CryptHTTPS/Encrypt.asp?a=GESPAY35928&b=mamma&c=2.0",
                 @c.send(:encrypt_url, "mamma")
  end
    
  def test_crypt_request_post_ssl
    assert_instance_of(Net::HTTPOK, @c.send(:post_ssl, @c.send(:encrypt_url, "mamma")))
  end
  
  def test_crypt_request_encrypt_returns_transaction_ok
    t = @c.encrypt(@t)
    assert_instance_of(GestPay::TransactionData, t)
    assert_nil t[:error_code]
  end
  
  def test_crypt_request_error_546
    @c.shop_login = ""
    t = @c.encrypt(@t)
    assert_equal "shop_login not valid", t[:error_description]
    assert_equal 546, t[:error_code]
  end
  
  def test_crypt_request_other_errors
    @t[:currency] = nil
    t = @c.encrypt(@t)
    assert_not_nil t[:error_description]
  end
  
  def test_crypt_request_error_9999
    @c.shop_login = nil
    t = @c.encrypt(@t)
    assert_equal "Connection Error", t[:error_description]
    assert_equal 9999, t[:error_code]
  end
  
  def test_crypt_request_error_response
    @t[:exp_month] = 9
    t = @c.encrypt(@t)
    assert_equal 1107, t[:error_code]
    assert_equal "Unexpected parameter name. Please double check Fields and Parameters configuration in Back Office.", t[:error_description]
  end
  
  def test_crypt_request_decrypt_url
    assert_equal "/CryptHTTPS/Decrypt.asp?a=GESPAY35928&b=mamma&c=2.0",
                 @c.send(:decrypt_url, "mamma")
  end
  
  def test_crypt_request_decrypt_returns_transaction_ok
    t = @c.decrypt(@encrypted_string)
    assert_instance_of(GestPay::TransactionData, t)
    assert_nil t[:error_description]
    assert_nil t[:error_code]
  end
  
  def test_crypt_request_decrypt_error
    t = @c.decrypt("william")
    assert_equal "System Error", t[:error_description]
    assert_equal 9999, t[:error_code]
  end
  
  def test_decrypt_request_error_546
    @c.shop_login = ""
    t = @c.decrypt(@encrypted_string)
    assert_instance_of(GestPay::TransactionData, t)
    assert_equal "shop_login not valid", t[:error_description]
    assert_equal 546, t[:error_code]
  end
  
  def test_decrypt_request_error_1009
    t = @c.decrypt("")
    assert_equal "String to Decrypt not valid", t[:error_description]
    assert_equal 1009, t[:error_code]
  end
  
end
