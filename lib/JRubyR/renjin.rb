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

require 'java'
require 'securerandom'

require_relative 'index'
require_relative 'vector'
require_relative 'rbsexp'

class Renjin
  include_package "javax.script"
  include_package "org.renjin"

  #----------------------------------------------------------------------------------------
  # This is the internal representation R uses to
  # represent NAs: a "quiet NaN" with a payload of 1954 (0x07A2).
  # <p/>
  # <p>The Java Language Spec is somewhat ambiguous regarding the extent to which
  # non-canonical NaNs will be preserved. What is clear though, is that signaled bit
  # (bit 12) is dropped by {@link Double#longBitsToDouble(long)}, at least on the few
  # platforms on which I have tested the Sun JDK 1.6.
  # <p/>
  # <p>The payload, however, does appear to be preserved by the JVM.
  #----------------------------------------------------------------------------------------

  NA = Java::OrgRenjinSexp.DoubleVector::NA
  Double_NA = NA

  #----------------------------------------------------------------------------------------
  # The double constant used to designate elements or values that are
  # missing in the statistical sense, or literally "Not Available". The following
  # has the relationships hold true:
  # <p/>
  # <ul>
  # <li>isNaN(NA) is <i>true</i>
  # <li>isNA(Double.NaN) is <i>false</i>
  # </ul>
  #----------------------------------------------------------------------------------------

  NaN = Java::OrgRenjinSexp.DoubleVector::NaN
  Double_NaN = NaN

  EPSILON = Java::OrgRenjinSexp.DoubleVector::EPSILON
  Int_NA = Java::OrgRenjinSexp.IntVector::NA

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  attr_reader :engine

  # Parse error
  ParseError=Class.new(Exception)

  #----------------------------------------------------------------------------------------
  # R is invoked within a Ruby script (or the interactive "irb" prompt denoted >>) using:
  #
  #      >> require "scicom"
  #
  # The previous statement reads the definition of the RinRuby class into the current Ruby 
  # interpreter and creates an instance of the RinRuby class named R. There is a second 
  # method for starting an instance of R which allows the user to use any name for the 
  # instance, in this case myr:
  #
  #      >> require "scicom"
  #      >> myr = RinRuby.new
  #      >> myr.eval "rnorm(1)"
  #
  # Any number of independent instances of R can be created in this way.
  #----------------------------------------------------------------------------------------

  def initialize

    @platform = 
      case RUBY_PLATFORM
      when /mswin/ then 'windows'
      when /mingw/ then 'windows'
      when /bccwin/ then 'windows'
      when /cygwin/ then 'windows-cygwin'
      when /java/
        require 'java' #:nodoc:
        if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
          'windows-java'
        else
          'default-java'
        end
      else 'default'
      end

    factory = Java::JavaxScript.ScriptEngineManager.new()
    @engine = factory.getEngineByName("Renjin")
    
  end

  #----------------------------------------------------------------------------------------
  # Converts an MDArray shape or index onto an equivalent R shape or index
  #----------------------------------------------------------------------------------------

  def ri(shape)

    rshape = shape.clone

    if (rshape.size > 2)
      rshape.reverse!
      rshape[0], rshape[1] = rshape[1], rshape[0]
    end
    rshape.map{ |val| (val + 1) }

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def nan?(x)
    Java::OrgRenjinSexp.DoubleVector.isNaN(x)
  end

  #----------------------------------------------------------------------------------------
  # The integer constant used to designate elements or values that are
  # missing in the statistical sense, or literally "Not Available". 
  # For integers (Fixnum) this is represented as the minimum integer from Java 
  # Integer.MIN_VALUE
  #----------------------------------------------------------------------------------------

  def na?(x)

    if (x.is_a?(Fixnum))
      Java::OrgRenjinSexp.IntVector.isNA(x)
    elsif (x.is_a?(Float))
      Java::OrgRenjinSexp.DoubleVector.isNA(x)
    else
      false
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def finite?(x)
    Java::OrgRenjinSexp.DoubleVector.isFinite(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def method_missing(symbol, *args)

    stack = Array.new

    name = symbol.id2name
    if name =~ /(.*)=$/
      # should never reach this point.  Parse error... but check
      raise ArgumentError, "You shouldn't assign nil" if args==[nil]
      super if args.length != 1
      ret = assign($1,args[0])
    else
      name.sub!(/__/,".")
      # super if args.length != 0
      if (args.length == 0)
        ret = pull(name)
      else
        params, stack = parse(*args)
        # p params
        ret = eval("#{name}(#{params})")
      end
    end

    stack.each do |sexp|
      sexp.destroy
    end

    ret

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def eval(expression)
    begin
      RubySexp.build(@engine.eval(expression))
    rescue Java::OrgRenjinEval::EvalException => e 
      p "Unmatched positional arguments"
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def direct_eval(expression)
    begin
      @engine.eval(expression)
    rescue Java::OrgRenjinEval::EvalException => e 
      p "Unmatched positional arguments"
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def parse(*args)

    params = Array.new
    stack = Array.new

    args.each do |arg|
      if (arg.is_a? Numeric)
        params << arg
      elsif(arg.is_a? String)
        params << "\"#{arg}\""
      elsif (arg.is_a? Symbol)
        # params << "\"#{arg.to_s}\""
        var = eval("#{arg.to_s}")
        params << var.r
      elsif (arg.is_a? TrueClass)
        params << "TRUE"
      elsif (arg.is_a? FalseClass)
        params << "FALSE"
      elsif (arg.is_a? Range)
        params << "(#{arg.begin}:#{arg.end})"
      elsif (arg.is_a? Hash)
        arg.each_pair do |key, value|
          params << "#{key.to_s} = #{parse(value)}"
        end
      elsif ((arg.is_a? MDArray)  || (arg.is_a? RubySexp))
        params << arg.r(stack)
      else
        raise "Unknown parameter type for R: #{arg}"
      end
      
    end

    [params.join(","), stack]
      
  end

  #----------------------------------------------------------------------------------------
  # Data is copied from Ruby to R using the assign method or a short-hand equivalent. For 
  # example:
  #
  #      >> names = ["Lisa","Teasha","Aaron","Thomas"]
  #      >> R.assign "people", names
  #      >> R.eval "sort(people)"
  #
  #produces the following :
  #
  #      [1] "Aaron"     "Lisa"     "Teasha" "Thomas"
  #
  # The short-hand equivalent to the assign method is simply:
  #
  #      >> R.people = names
  #
  # Some care is needed when using the short-hand of the assign method since the label 
  # (i.e., people in this case) must be a valid method name in Ruby. For example, 
  # R.copy.of.names = names will not work, but R.copy_of_names = names is permissible.
  #
  # The assign method supports Ruby variables of type Fixnum (i.e., integer), Bignum 
  # (i.e., integer), Float (i.e., double), String, and arrays of one of those three 
  # fundamental types. Note that Fixnum or Bignum values that exceed the capacity of R's 
  # integers are silently converted to doubles.  Data in other formats must be coerced 
  # when copying to R.
  #
  # <b>Parameters that can be passed to the assign method:</b>
  #
  # * name: The name of the variable desired in R.
  # * value: The value the R variable should have.
  #
  # The assign method is an alternative to the simplified method, with some additional 
  # flexibility. When using the simplified method, the parameters of name and value are 
  # automatically used, in other words:
  #
  #      >> R.test = 144
  #
  # is the same as:
  #
  #      >> R.assign("test",144)
  #
  # Of course it would be confusing to use the shorthand notation to assign a variable 
  # named eval, echo, or any other already defined function. RinRuby would assume you were 
  # calling the function, rather than trying to assign a variable.
  #
  # When assigning an array containing differing types of variables, RinRuby will follow 
  # R’s conversion conventions. An array that contains any Strings will result in a 
  # character vector in R. If the array does not contain any Strings, but it does contain 
  # a Float or a large integer (in absolute value), then the result will be a numeric 
  # vector of Doubles in R. If there are only integers that are suffciently small (in 
  # absolute value), then the result will be a numeric vector of integers in R.
  #----------------------------------------------------------------------------------------

  def assign(name, value)

    original_value = value

    if (value.is_a?(MDArray))
      if (value.sexp != nil)
        # MDArray already represented in R
        value = value.sexp
      else
        value.immutable
        value = build_vector(value)
      end
    end

    @engine.put(name, value)
    original_value
    
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def pull(name)
    eval(name)
  end

  #----------------------------------------------------------------------------------------
  # Builds a Renjin vector from an MDArray. Should be private, but public for testing.
  #----------------------------------------------------------------------------------------

  def build_vector(array)

    shape = array.shape
    index = array.nc_array.getIndex()
    # index = MDArray.index_factory(shape)
    # representation of shape in R in different from shape in MDArray.  Convert MDArray
    # shape to R shape.
    if (shape.size > 2)
      shape.reverse!
      shape[0], shape[1] = shape[1], shape[0]
    end
    # AttributeMap attributes = AttributeMap.builder().setDim(new IntVector(dim)).build();
    attributes = Java::OrgRenjinSexp::AttributeMap.builder()
      .setDim(Java::OrgRenjinSexp::IntArrayVector.new(*(shape))).build()
    vector = Java::RbScicom::MDDoubleVector.new(array.nc_array, attributes, index,
                                                index.stride)
    
  end


end

# Create a new R interpreter
R = Renjin.new
