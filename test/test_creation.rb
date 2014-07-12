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

  context "R environment" do

    #======================================================================================
    #======================================================================================

    setup do 

      # creating two distinct instances of SciCom
      @r1 = R.new
      @r2 = R.new

    end
=begin
    #======================================================================================
    #
    #======================================================================================

    should "be able to check some properties of numbers" do

      # all are not NA (not available)
      assert_equal(false, R.na?(10))
      assert_equal(false, R.na?(10.35))
      assert_equal(false, R.na?(@r1.eval("10L")))
      assert_equal(false, R.na?(@r1.eval("10.456")))
      assert_equal(false, R.na?(nil))

      # Double_NaN is not considered NA
      assert_equal(false, R.na?(R.Double_NaN))
      
      assert_equal(true, R.na?(R.Int_NA))

      # Those are NaN
      assert_equal(true, R.nan?(R.Double_NA))
      assert_equal(true, R.nan?(R.Double_NaN))
      
      # Check if the number if finite
      assert_equal(true, R.finite?(10))
      assert_equal(true, R.finite?(10.35))

      # chekc numbers to see if they are finite
      assert_equal(false, R.finite?(R.Double_NaN))

      assert_equal(false, R.finite?(R.Double_NA))
      assert_equal(false, R.finite?(R.Double_NaN))

      # The notion of "finite" does not apply to Vectors
      assert_raise (TypeError) { R.finite?(@r1.eval("10L")) }
      assert_raise (TypeError) { R.finite?(@r1.eval("10.456")) }
      
      # Int_NA is finite; however Double_NA is not finite.  Is this correct? Should 
      # check with the Renjin team.
      assert_equal(true, R.finite?(R.Int_NA))

      # In the same vein as above, shouldn't nil be considered NaN?  Guess not.  In 
      # R the result of is.nan(NULL) is logical(0)
      assert_equal(false, R.nan?(nil))
      assert_equal(false, R.nan?(@r1.eval("NULL")))

    end


    #======================================================================================
    #======================================================================================

    should "be able to assign NULL to R object" do
      
      # assign NULL value
      @r.assign("nl", "NULL")
      res = @r.pull("nl")
      assert_equal(res, nil)

      @r.n2 = "NULL"
      res = @r.n2
      assert_equal(res, nil)

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to assign an integer to an R object" do

      @r1.eval("i1 = 10L")
      i1 = @r1.i1
      assert_equal("integer", i1.type_name)

      assert_equal(10, i1.get)
      assert_equal(10, i1[0])
      assert_equal(10, i1.get_as(:int))
      assert_equal(10.0, i1.get_as(:double))
      assert_equal("10", i1.get_as(:string))
      # assert_equal(true, i1.get_as(:logical))
      # assert_equal(1, i1.get_as(:raw_logical))
      # assert_equal(Complex(10, 0), i1.get_as(:complex))

      assert_equal(true, i1.element_true?)
      assert_raise (IndexError) { i1.element_true?(1) }

    end

=end

    #======================================================================================
    #
    #======================================================================================

    should "be able to assign a double to an R object" do

      @r1.eval("i1 = 10.2387")
      # the returned value is an MDArray and all methods on MDArray can be called
      i1 = @r1.i1

      assert_equal("double", i1.type_name)

      assert_equal(10, i1.get_as(:int))
      assert_equal(10.2387, i1.get_as(:double))
      assert_equal("10.2387", i1.get_as(:string))
      # assert_equal(true, i1.get_as(:logical))
      # assert_equal(1, i1.get_as(:raw_logical))
      # assert_equal(Complex(10.2387, 0), i1.get_as(:complex))

      # i1 from r2 should not interfere with i1 from r1
      @r2.i1 = 20.18 # store data in R engine r2
      r2_i1 = @r2.i1 # retrive i1 from R engine r2

      assert_equal(10.2387, i1[0])
      assert_equal(20.18, r2_i1[0])

      @r1.i2 = 10.35
      assert_equal(10, @r1.i2.get_as(:int))
      assert_equal(10.35, @r1.i2.get_as(:double))

      # should not be allowed as we are changing an R object outside of R.  Could cause
      # problems for Renjin
      i1[0] = 20
      val = @r1.eval("i1")
      val.print

    end

    #======================================================================================
    #
    #======================================================================================
=begin
    should "be able to assign a string to R" do

      @r1.assign("str", "hello there;")
      str = @r1.pull("str")

      p str.get_as(:int)
      p str.get_as(:double)
      p str.get_as(:complex)

      assert_equal("hello there;", str.get_as(:string))
      assert_equal("hello there;", str.get)

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to assign a Ruby array to R" do

      names = ["Lisa", "Teasha", "Aaron", "Thomas"]
      @r1.people = names
      # @r1.people.get_element_as_string

    end
    
    #======================================================================================
    #
    #======================================================================================

    should "be able to send an MDArray to R" do


    end
=end

  end
  
end
