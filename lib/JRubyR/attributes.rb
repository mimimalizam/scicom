# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
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

#==========================================================================================
#
#==========================================================================================

class Renjin

  class Attributes

    attr_reader :rbsexp

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def initialize(rbsexp)
      @rbsexp = rbsexp
    end

    #----------------------------------------------------------------------------------------
    # When accessing an attribute, we need to keep track of the object that holds the
    # attribute.  This is necessary for the following construct to work:
    # elmt.attr.name = "name".  In this case, we need to change the attribute of elmt and
    # in R this is done by elmt.attr <- name. But when parsing Ruby, when we get to
    # elmt.attr.name, it is to late.
    #----------------------------------------------------------------------------------------
    
    def method_missing(symbol, *args)
      
      name = symbol.id2name
      name.sub!(/__/,".")
      # Method 'rclass' is a substitute for R method 'class'.  Needed, as 'class' is also
      # a Ruby method on an object
      name.gsub!("rclass", "class")
      
      if name =~ /(.*)=$/
        args = R.parse(*args)
        ret = R.eval("attr(#{@rbsexp.r}, \"#{name.delete!('=')}\") = #{args}")
      else
        if (args.length == 0)
          # p "retrieving attribute: #{name}"
          ret = R.eval("attr(#{@rbsexp.r}, \"#{name}\")")
          ret.scope = ["attr", @rbsexp, name]
        else
          raise "An attribute cannot have parameters"
        end
      end

      ret
      
    end
    
  end
  
end
