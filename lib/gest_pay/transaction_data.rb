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

module GestPay
  class TransactionData

    # Configuration Data
    attr_accessor :separator, :encrypted_str

    REQUEST_MAPPINGS = {
      "PAY1_"            => :custom_info,     
      "PAY1_AMOUNT"      => :amount,
      "PAY1_CARDNUMBER"  => :card_number,
      "PAY1_CHEMAIL"     => :buyer_email,
      "PAY1_CHNAME"      => :buyer_name,
      "PAY1_CVV"         => :cvv,
      "PAY1_EXPMONTH"    => :exp_month,
      "PAY1_EXPYEAR"     => :exp_year,
      "PAY1_IDLANGUAGE"  => :language,
      "PAY1_MIN"         => :min,
      "PAY1_SHOPTRANSACTIONID" => :shop_transaction_id,
      "PAY1_UICCODE"           => :currency
    }

    RESPONSE_MAPPINGS = {
      "PAY1_ALERTCODE" => :alert_code,
      "PAY1_ALERTDESCRIPTION" => :alert_description,
      "PAY1_AUTHORIZATIONCODE" => :authorization_code,
      "PAY1_BANKTRANSACTIONID" => :bank_transaction_id,
      "PAY1_COUNTRY" => :country,
      "PAY1_IDLANGUAGE" => :language,
      "PAY1_TRANSACTIONRESULT" => :transaction_result,
      "PAY1_VBV" => :vbv,
      "PAY1_VBVRISP" => :vbvrisp
    }

    ERROR_MAPPINGS = {
      "PAY1_ERRORCODE" => :error_code,
      "PAY1_ERRORDESCRIPTION" => :error_description
    }

    def initialize(attributes = nil)
      @separator = "*P1*"
      @attributes = {:encrypted_str => nil}
      REQUEST_MAPPINGS.merge(RESPONSE_MAPPINGS).merge(ERROR_MAPPINGS).each_value do |v|
        @attributes = @attributes.merge({v => nil})
      end
      if attributes.respond_to? :has_key?
        create_from_hash attributes
      elsif attributes.respond_to? :to_str
        create_from_string attributes.to_str
      end
    end

    def to_str
      string = ""
      REQUEST_MAPPINGS.each do |key, value|
          string += @separator + key + "=" + CGI.escape(@attributes[value].to_s) unless @attributes[value].nil?
        end
      string[@separator.length..-1]
    end

    def [](key)
      @attributes[key.to_sym]
    end

    def []=(key, value)
      if @attributes.has_key? key.to_sym
        @attributes[key.to_sym] = value
      else
        nil
      end
    end

    def ready_to_encrypt?
      !(
      (@attributes[:currency].nil? || @attributes[:currency].size == 0) ||
      (@attributes[:amount].nil? || @attributes[:amount].size == 0) ||
      (@attributes[:shop_transaction_id].nil? || @attributes[:shop_transaction_id].size == 0)
      )
    end

    def encrypt_error
      unless ready_to_encrypt?
        if (@attributes[:currency].nil? || @attributes[:currency].size == 0)
          {:error_code => 552, :error_description => "currency not valid"}
        elsif (@attributes[:amount].nil? || @attributes[:amount].size == 0)
          {:error_code => 553, :error_description => "amount not valid"}
        elsif (@attributes[:shop_transaction_id].nil? || @attributes[:shop_transaction_id].size == 0)
          {:error_code => 551, :error_description => "shop_transaction_id not valid"}
        end
      else
        {:error_code => nil, :error_description => nil}
      end
    end

    private

    def create_from_hash attributes
      attributes.each do |key, value|
        if @attributes.has_key? key.to_sym
          @attributes[key.to_sym] = value unless value.nil? || value == ""
        end
      end
    end

    def create_from_string attributes
      @attributes[:custom_info] = ""
      Hash[*attributes.split(/#{Regexp.escape(@separator)}|=/)].each do |key, value|
        if @attributes.has_key? map_attribute_key(key)
          @attributes[map_attribute_key(key)] = CGI.unescape(value)
        else 
          @attributes[:custom_info] << @separator + CGI.unescape(key) + "=" + CGI.unescape(value)
        end
      end
      @attributes[:custom_info] = nil if @attributes[:custom_info].size == 0
      if @attributes[:error_code] == "0"
        @attributes[:error_code] = nil
        @attributes[:error_description] = nil
      end
    end

    def map_attribute_key(key)
      REQUEST_MAPPINGS.merge(RESPONSE_MAPPINGS).merge(ERROR_MAPPINGS)[key]
    end
  end
end