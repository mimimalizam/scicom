# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'rubygems'
require "test/unit"
require 'shoulda'

require 'env'
require 'scicom'

class SciComTest < Test::Unit::TestCase

  context "R Vectors" do

    #======================================================================================
    #
    #======================================================================================

    setup do 

    end

    #======================================================================================
    #
    #======================================================================================

    should "create all types of vectors and check basic properties" do

      dbl_var = R.c(1, 2.5, 4.5)
      assert_equal(2.5, dbl_var[1])
      assert_equal("double", dbl_var.typeof)
      assert_equal(3, dbl_var.length)
      assert_equal(false, dbl_var.integer?)
      assert_equal(true, dbl_var.double?)
      assert_equal(true, dbl_var.numeric?)

      R.eval("attr(#{dbl_var.r}, \"name\") <- \"my.attr\"") 
      R.eval("print(attributes(#{dbl_var.r}))")
      R.eval("print(attr(#{dbl_var.r}, \"name\"))")

      R.eval <<EOF
         l = list(1, 2, 3, 4)
         attr(l, "name") = "my.name"
         print(attributes(l))
EOF
      att = R.attributes(dbl_var)
      p att

      # With the L suffix, you get an integer rather than a double
      int_var = R.c(R.i(1), R.i(6), R.i(10))
      assert_equal("integer", int_var.typeof)
      assert_equal(3, int_var.length)
      assert_equal(true, int_var.integer?)
      
      # Use TRUE and FALSE (or T and F) to create logical vectors
      log_var = R.c(TRUE, FALSE, TRUE, FALSE)
      assert_equal("logical", log_var.typeof)
      assert_equal(4, log_var.length)
      assert_equal(true, log_var.logical?)

      chr_var = R.c("these are", "some strings")
      assert_equal("character", chr_var.typeof)
      assert_equal(2, chr_var.length)
      assert_equal(true, chr_var.character?)
      assert_equal(true, chr_var.atomic?)
      assert_equal(false, chr_var.numeric?)

      v1 = R.c(1, R.c(2, R.c(3, 4)))
      v1.print

      vec2 = R.rep(R.c("A", "B", "C"), 3)
      vec2.print
      table = R.table(vec2)
      table.print

      # Ruby does not allow the ":" notation such as "1:3", this can be obtained
      # by Ruby's range notation (1..3) or (1...3)
      v2 = R.c((1...3))
      v2.print

      v3 = R.c((1..3))
      v3.print

    end

  end

end
