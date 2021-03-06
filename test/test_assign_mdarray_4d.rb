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

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end


=begin    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with MDArray slices" do

      dim = [6, 4, 3, 2]

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, dim.inject(:*))
      arr1.reshape!(dim)
      
      slice = arr1.slice(0, 0)
      slice.print
      mat = R.md(slice)
      mat.pp

      slice = arr1.slice(0, 1)
      slice.print
      mat = R.md(slice)
      mat.pp

    end
=end    
  end
  
end

