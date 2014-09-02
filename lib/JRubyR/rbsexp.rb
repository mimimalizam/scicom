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

require_relative "attributes"

#==========================================================================================
#
#==========================================================================================

class Java::OrgRenjinSexp::StringArrayVector
  field_reader :values
end

#==========================================================================================
#
#==========================================================================================

module RBSexp
  include_package "org.renjin"
  include_package "java.lang"
  
  attr_reader :sexp
  attr_reader :rvar

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def destroy
    
    if (@rvar != nil)
      R.direct_eval("rm('#{@rvar}')")
      @rvar = nil
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def r

    if (@rvar == nil)
      @rvar = "sc_#{SecureRandom.hex(8)}"
      (@sexp == nil)? R.assign(@rvar, self) : R.assign(@rvar, @sexp)
      # Whenever a variable is injected in Renjin, it is also added to the Renjin stack.
      # After eval, every injected variable is removed from Renjin making sure that we
      # do not have memory leak.
      Renjin.stack << self
    end

    @rvar

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def set_sexp(sexp)
    @sexp = sexp
  end

  #----------------------------------------------------------------------------------------
  # * @return true if this MDArray already points to a sexp in R environment
  #----------------------------------------------------------------------------------------

  def sexp?
    sexp != nil
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def print
    R.eval("print(#{r})")
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def pp
    print
  end

end

#==========================================================================================
#
#==========================================================================================

class Renjin

  class RubySexp
    include RBSexp
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def initialize(sexp)
      @sexp = sexp
      @rvar = nil
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def to_string
      R.eval("toString(#{r})")
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def self.build(sexp)
      
      if (sexp.instance_of? Java::OrgRenjinPrimitivesSequence::IntSequence)
        res = Renjin::IntSequence.new(sexp)
      elsif (sexp.instance_of? Java::OrgRenjinSexp::Null)
        res = nil
      elsif (sexp.instance_of? Java::OrgRenjinSexp::ListVector)
        res = Renjin::List.new(sexp)
      elsif (sexp.instance_of? Java::OrgRenjinSexp::LogicalArrayVector)
        res = Renjin::Logical.new(sexp)
      elsif (sexp.instance_of? Java::OrgRenjinSexp::Environment)
        res = Renjin::Environment.new(sexp)
      elsif (sexp.is_a? Java::OrgRenjinSexp::Vector)
        res = Renjin::Vector.new(sexp)
      else
        p "sexp type needs to be specialized"
        p sexp
        res = Renjin::RubySexp.new(sexp)
      end
      
      return res
      
    end
    
  end

end

require_relative 'vector'
require_relative 'sequence'
require_relative 'list'
require_relative 'logical_value'
require_relative 'environment'
