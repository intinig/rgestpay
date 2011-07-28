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

require 'cgi'
require 'net/https'
require File.dirname(__FILE__) + '/gest_pay/transaction_data.rb'
require File.dirname(__FILE__) + '/gest_pay/crypt_request.rb'

module GestPay
end