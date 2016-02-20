# coding: utf-8
require '../config'
require 'scicom'
require_relative 'rbmarkdown'

# title("A (not so) Short Introduction to SciCom")

author("Rodrigo Botafogo")

body(<<-EOT)
This paper introduces and compares SciCom with R's S4.  It is a shameless rip off of 
#{ref("A '(not so)' Short Introduction to S4", 
"https://cran.r-project.org/doc/contrib/Genolini-S4tutorialV0-5en.pdf")} by Christophe Genolini
and follows the same structure and examples presented there.

SciCom is a Ruby Gem (library) that allows very tight integration between Ruby and R.  
It's integration is
much tigher and transparent from what one can get beetween RinRuby or similar solutions in Python
such as PypeR (https://pypi.python.org/pypi/PypeR/1.1.0), rpy2 (http://rpy2.bitbucket.org/) and 
other similar solutions.  SciCom targets the Java Virtual Machine and it
integrates with Renjin (http://www.renjin.org/), an R interpreter for Java.  

From the Renjin page we can get the following description of Renjin and its objectives:

The goal of Renjin 
is to eventually be compatible with GNU R such that most existing R language programs will 
run in Renjin without the need to make any changes to the code. Needless to say, Renjin is 
currently not 100% compatible with GNU R so your mileage may vary. 

The biggest advantage of Renjin is that the R interpreter itself is a Java module which can be 
seamlessly integrated into any Java application. This dispenses with the need to load dynamic 
libraries or to provide some form of communication between separate processes. These types of 
interfaces are often the source of much agony because they place very specific demands on the 
environment in which they run.

We frenquently see on the web people asking: "which is better for data analysis: R or Python?" In
This article we also have the objetive to try to answer this question.  As you will see, our 
point is: "when in doubt about R or Python, use SciCom!"

EOT

subsubsection("Limitations")

body(<<-EOT)
Unfortunately, SciCom has three main limitations, and although we think that "use Scicom!" is a 
good catch phrase, at this point we don't see SciCom as being able to substitute R.  The three
limitations are:

* Renjin has implemented all of base R (maybe still some bugs, I don't know!), but there are still
many packages that do not yet work with it.  Renjin is making huge steps forward, but for the
standard R user, chances are that her preferred package does not yet run in Renjin;
* Renjin does not implement any of the graph functionality such as plot or ggplot and has intention
to do so.  Ruby has some graphing libraries, but they are still not "au par" with ggplot nor 
matplotlib;
* SciCom does not have a large user community.  Actually it does not even have a small user 
community.  Without a user community, no free software can survive.  I hope this paper will help
attract some people to this new community.
EOT

chapter("Bases of Object Programming")

body(<<-EOT)
In this paper, we will start our discussion from Part II of "The (not so) Short Introduction 
to S4", which from now on we will reference as SS4 for "short S4". Interested readers are directed 
to this paper to understand the motivation and examples in that paper.  In this paper we will
present the S4 code from SS4 and then the same code in Ruby/SciCom.  We will not comment on the
S4 code, as all the comments can be found in SS4, we will only focus on the Ruby/SciCom 
description.

S4 defines classes by using the setClass function:
EOT

section("Classes Declaration")

comment_code(<<-EOT)
# > setClass(
# + Class="Trajectories",
# + representation=representation(
# + times = "numeric",
# + traj = "matrix"
# + )
# + )
EOT

subsection("Instance Variables")

body(<<-EOT)
In Ruby a class is defined by the keyword 'class'.  Every class should start with a capital 
letter.  S4 'slots' are called 'instance variables' in Ruby.  Differently from R's S4, 
instance variables in Ruby do not have type information.  It should be clear though, that S4
type information is also not a "compile" time type, since R is not compiled.  The type is 
checked at runtime.  The same checking can be done in Ruby and we will do it later in this 
document.

In the example bellow, we create 
class Trajectories with two instance variables, 'times' and 'matrix'.  We will not go over 
the details of instance variables in Ruby, but here we created those variables with the 
keyword 'attr_reader' and a colomn before the variables name:
EOT

code(<<-EOT)
class Trajectories

  attr_reader :times
  attr_reader :matrix

end

EOT

body(<<-EOT)
In order to create a new instance of object Trajectories we call method new on the class and
we can store the result in a varible (not an instance variable) as bellow:
EOT

console(<<-EOT)
traj = Trajectories.new
EOT

body(<<-EOT)
We now have in variable 'traj' a Trajectories object.  In Ruby, printing variable 'traj' will 
only print the class name of the object and not it contents as in R.  
EOT

console(<<-EOT)
puts traj
EOT

body(<<-EOT)
To see the contents of an object, one needs to access its components using the '.' operator:
EOT

console(<<-EOT)
puts traj.times
EOT

subsection("Constructor")

body(<<-EOT)
Since there is no content stored in 'times' nor 'matrix', nil is returned.  In order to add
a value in the variables, we need to add a contructor the class Trajectories.  In R, a 
constructor is build by default, in Ruby, this has to be created by adding a method called
'initialize'.  In the example bellow, we will create the initializer that accepts two values,
a 'times' value and a 'matrix' value and they are used to initialize the value of the 
instance variables:
EOT

code(<<-EOT)

class Trajectories
  
  attr_reader :times
  attr_reader :matrix

  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix
  end

end

EOT

body(<<-EOT)
Up to this point, everything described in pure Ruby code and has absolutely no relationship is R.
We now want to create a Trajectories with a 'times' vector.  Ruby has a vector class and we could
use this class to create a vector and add it to the 'times' instance variable; however, in order
to make use of R's functions, we want to create a R vector to add to 'times'.  In SciCom, 
creating R objects is done using the corresponding R functions by just preceding them with 'R.',
i.e., R functions are all defined in SciCom in the R namespace.

Since SciCom is Ruby and not R, some syntax adjustments are sometimes necessary.  For instance,
in R, a range is represented as '(1:4)', in Ruby, the same range is represented as '(1..4)'. 
When passing arguments to an R funciton in R one uses the '=' sign after the slot name; in R,
one uses the ':' operator after parameter's name as we can see bellow:
EOT

code(<<-EOT)
# Create a Trajectories with the times vector [1, 2, 3, 4] and not matrix
traj = Trajectories.new(times: R.c(1, 2, 3, 4))

# Create a Trajectories with times and matrix
traj2 = Trajectories.new(times: R.c(1, 3), matrix: R.matrix((1..4), ncol: 2))
EOT

subsection("Access to Instance Variables (to reach a slot)")

body(<<-EOT)
In order to access data in an instace variable the operator '.' is used.  In R, a similar
result is obtained by use of the '@' operator, but SS4 does not recomend its use.  In SciCom,
the '.' operator is the recomended way of accessing an instance variable.
 
Now that we have created two trajectories, let's try to print its instance variables to see 
that everything is fine:
EOT

console(<<-EOT)
puts traj.times
EOT

body(<<-EOT)
Well this wasn't really what we had expected... as explained before, printing a variable, will
actually only show the class name and vector 'times' in SciCom is actually a Renjin::Vector.
In order to print the content of a SciCom object we use method 'pp' as follows:
EOT

console(<<-EOT)
traj.times.pp
EOT

body(<<-EOT)
We now have the expected value.  Note that the 'times' vector is printed exactly as it would
if we were using GNU R.  Let's now take a look at variable 'traj2':
EOT

console(<<-EOT)
traj2.times.pp
EOT

console(<<-EOT)
traj2.matrix.pp
EOT

body(<<-EOT)
Let's now build the same examples as in SS4:  Three hospitals take part in a 
study. The Pitié Salpêtriere (which has not yet returned its data file, shame on them!),
Cochin and Saint-Anne.  We first show the code in R and the the corresponding SciCom:
EOT

comment_code(<<-EOT)
> trajPitie <- new(Class="Trajectories")
> trajCochin <- new(
+     Class= "Trajectories",
+     times=c(1,3,4,5),
+     traj=rbind (
+         c(15,15.1, 15.2, 15.2),
+         c(16,15.9, 16,16.4),
+         c(15.2, NA, 15.3, 15.3),
+         c(15.7, 15.6, 15.8, 16)
+     )
+ )
> trajStAnne <- new(
+     Class= "Trajectories",
+     times=c(1: 10, (6: 16) *2),
+     traj=rbind(
+         matrix (seq (16,19, length=21), ncol=21, nrow=50, byrow=TRUE),
+         matrix (seq (15.8, 18, length=21), ncol=21, nrow=30, byrow=TRUE)
+     )+rnorm (21*80,0,0.2)
+ )
EOT

body(<<-EOT)
This same code in SciCom becomes:
EOT

code(<<-EOT)
trajPitie = Trajectories.new
EOT

code(<<-EOT)
trajCochin = Trajectories.new(times: R.c(1,3,4,5),
                              matrix: R.rbind(
                                R.c(15,15.1, 15.2, 15.2),
                                R.c(16,15.9, 16,16.4),
                                R.c(15.2, NA, 15.3, 15.3),
                                R.c(15.7, 15.6, 15.8, 16)))
EOT

code(<<-EOT)
trajStAnne =
  Trajectories.new(times: R.c((1..10), R.c(6..16) * 2),
                   matrix: (R.rbind(
                             R.matrix(R.seq(16, 19, length: 21), ncol: 21,
                                      nrow: 50, byrow: true),
                             R.matrix(R.seq(15.8, 18, length: 21), ncol: 21,
                                      nrow: 30, byrow: true)) + R.rnorm(21*80, 0, 0.2)))

EOT

body(<<-EOT)
Let's check that the 'times' and 'matrix' instace variables were correctly set:
EOT

console(<<-EOT)
trajCochin.times.pp
EOT

console(<<-EOT)
trajCochin.matrix.pp
EOT

console(<<-EOT)
trajStAnne.times.pp
EOT

body(<<-EOT)
We will not at this time print trajStAnne.matrix, since this is a huge matrix and the result
would just take too much space.  Later we will print just a partial view of the matrix.
EOT

subsection("Default Values")

body(<<-EOT)
Default values are very useful and quite often used in Ruby programs.  Although SS4 does not
recommend its use, there are many cases in which default values are useful and make code simpler.
We have already seen default values in this document, with the default being 'nil'.  This was
necessary in order to be able to create our constructor and passing it the propoper values.

In the example bellow, a class TrajectoriesBis is created with default value 1 for times and a 
matrix with no elements in matrix.
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_reader :times
  attr_reader :matrix

  def initialize(times: 1, matrix: R.matrix(0))
    @times = times
    @matrix = matrix
  end
  
end

traj_bis = TrajectoriesBis.new
EOT

body(<<-EOT)
Let's take a look at our new class:
EOT

console_error(<<-EOT)
traj_bis.times.pp
EOT

body(<<-EOT)
Well, not exactly what we had in mind.  We got an error saying that .pp is undefined for 
Fixnum.  In R, numbers are automatically converted to vectors, but this is not the case
in Ruby and SciCom.  In Ruby, numbers are numbers and vectors are vectors.  In the 
initialize method above, we stored 1 in variable @times and 1 is a number.  Method .pp is
only available for R objects.  

In order to fix this, we need to fix our initializer to convert number 1 to a vector with
one element of value 1.  SciCom provides the method R.i to do this conversion.  

When calling an R function that expects a number as argument, this conversion is
automatically done by SciCom; however, in the initialize method, there is no indication 
to SciCom that variable @times is actually a SciCom variable, since there is no type 
information.  In this case, we need to be explicit and use R.i:
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_reader :times
  attr_reader :matrix

  # Use R.i to convert number 1 to a vector
  def initialize(times: R.i(1), matrix: R.matrix(0))
    @times = times
    @matrix = matrix
  end
  
end

traj_bis = TrajectoriesBis.new
EOT

console(<<-EOT)
traj_bis.times.pp
EOT

console(<<-EOT)
traj_bis.matrix.pp
EOT

subsection("To Remove an Object")

body(<<-EOT)
As far as I know, there isn't a good way of removing a defined class, but there might be
one and the interested user is directed to google it!  In principle, there should not be
any real need to remove a defined class.  Both in R and SciCom, large programs are usually
written in a file and the file loaded.  If one writes a wrong class, the better solution is
to correct it on and then load it again.  If the class is written directly on the console,
then leaving it there will not have any serious impact.
EOT

subsection ("The Empty Object")

body(<<-EOT)
When a Trajectories is created with new, and no argument is given, all its instance variables
will have the default nil value.  Since Ruby has no type information, then there is only one
type (or actually no type) of nil.  To check if a variable is empty, we check it agains the nil
value.
EOT

subsection ("To See an Object")

body(<<-EOT)
Ruby has very strong meta-programming features, in particular, one can use instrospection to 
see methods and instance variables from a given class.  Method 'instance_variables' shows all
the instace variables of an object:
EOT

console(<<-EOT)
puts traj.instance_variables
EOT

body(<<-EOT)
The description of all meta-programming features of Ruby is well beyond the scope of this 
document, but it is a very frequent a powerful feature of Ruby, that makes programming in
Ruby a different experience than programming in other languages.
EOT

section ("Methods")

body(<<-EOT)
Methods are a fundamental feature of object oriented programming. We will now extend our class
Trajectories to add methods to it.  In SS4, a method 'plot' is added to Trajectories.  At this
point, Renjin and SciCom do not yet have ploting capabilities, so we will have to skip this 
method and go directly to the implementation of the 'print' method.

Bellow is the R code for method print:
EOT

comment_code(<<-EOT)
> setMethod ("print","Trajectories",
+ function(x,...){
+ cat("*** Class Trajectories, method Print *** \n")
+ cat("* Times ="); print (x@times)
+ cat("* Traj = \n"); print (x@traj)
+ cat("******* End Print (trajectories) ******* \n")
+ }
+ )
EOT

body(<<-EOT)
Now the same code for class Trajectories in Scicom.  In general methods are defined in a class
together with all the class definition.  We will first use this approach. Later, we will show
how to 'reopen' a class to add new methods to it.

In this example, we are defining a method named 'print'.  We have being using method 'puts' to
output data.  There is a Ruby method that is more flexible than puts and that we need to use to
implement our function: 'print'. However, trying to use Ruby print inside the definition of 
Trajectories's print will not work, as Ruby will understand that as a recursive call to print. 
Ruby's print is defined inside the Kernel class, so, in order to call Ruby's print inside the
definition of Trajectories's print we need to write 'Kernel.print'.
EOT

code(<<-EOT)
class Trajectories
  
  attr_reader :times
  attr_reader :matrix

  #
  # 
  #
  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix
  end

  def print
    puts("*** Class Trajectories, method Print *** ")
    Kernel.print("times = ")
    @times.pp
    puts("traj =")
    @matrix.pp
    puts("******* End Print (trajectories) ******* ")
  end
  
end
EOT

console(<<-EOT)
trajCochin.print
EOT

body(<<-EOT)
For Cochin, the result is correct. For Saint-Anne, print will display too much
information. So we need a second method.

Show is the default R method used to show an object when its name is written in the
console. We thus define 'show' by taking into account the size of the object: if there are too
many trajectories, 'show' posts only part of them.

Here is the R code for method 'show':
EOT

comment_code(<<-EOT)
> setMethod("show","Trajectories",
+ function(object){
+ cat("*** Class Trajectories, method Show *** \n")
+ cat("* Times ="); print(object@times)
+ nrowShow <- min(10,nrow(object@traj))
+ ncolShow <- min(10,ncol(object@traj))
+ cat("* Traj (limited to a matrix 10x10) = \n")
+ print(formatC(object@traj[1:nrowShow,1:ncolShow]),quote=FALSE)
+ cat("******* End Show (trajectories) ******* \n")
+ }
+ )
EOT

body(<<-EOT)
Now, let's write it with SciCom.  This time though, we will not rewrite the whole Trajectories
class, but just reopen it to add this specific method.  The next example has many interesting
features of SciCom, some we have already seen, others will be described now:
EOT

list(<<-EOT)
* As we have already seen, to call an R function one uses the R.<function> notation.  There
is however another way: when the first argument to the R function is an R object such as a
matrix, a list, a vector, etc. we can use '.' notation to call the function.  This makes the 
function look like a method of the object.  For instance, R.nrow(@matrix), can be called by
doing @matrix.nrow;
* In R, every number is converted to a vector and this can be done with method R.i.  Converting
a vector with only one number back to a number can be done with method '.gz'.  So if @num is
an R vector that holds a number, then @num.gz is a number that can be used normally with Ruby
methods;
* R functions and Ruby methods can be used freely in SciCom.  We show bellow two different ways
of getting the minimum of a number, either by calling R.min or by getting the minimum of an 
array, with the min method;
* SciCom allows for method 'chaining'. Method chaining, also known as named parameter idiom, is 
a common syntax for invoking multiple method calls in object-oriented programming languages. 
Each method returns an object, allowing the calls to be chained together in a single statement 
without requiring variables to store the intermediate results.  For instance @matrix.nrow.gz, 
which returns the number of rows of the matrix as a number;
* Ranges in Ruby are represented by (x..y), where x is the beginning of the range and y its end.
An R matrix can be indexed by range, object@traj[1:nrowShow,1:ncolShow], the same result is 
obtained in SciCom by indexing @matrix[(1..nrow_show), (1..ncol_show)].  Observe that this
statement is then chained with the format function and with the pp method to print the matrix.
EOT

code(<<-EOT)
class Trajectories

  def show
    puts("*** Class Trajectories, method Show *** ")
    Kernel.print("times = ")
    @times.pp
    nrow_show = [10, @matrix.nrow.gz].min
    ncol_show = R.min(10, @matrix.ncol).gz
    puts("* Traj (limited to a matrix 10x10) = ")
    @matrix[(1..nrow_show), (1..ncol_show)].format(digits: 2, nsmall: 2).pp
    puts("******* End Show (trajectories) ******* ")
  end
  
end
EOT

console(<<-EOT)
trajStAnne.show
EOT

body(<<-EOT)
Our show method has the same problem as SS4, i.e., if an empty trajectories object is created and
we try to 'show' it, it will generate an error.  Let's see it:
EOT

code(<<-EOT)
empty_traj = Trajectories.new
EOT

console_error(<<-EOT)
empty_traj.show
EOT

comment_code(<<-EOT)
NoMethodError: undefined method `pp' for nil:NilClass
     show at :6
   <eval> at :1
     eval at org/jruby/RubyKernel.java:976
  console at T:/Rodrigo/Desenv/SciCom/examples/rbmarkdown.rb:61
    <top> at T:\Rodrigo\Desenv\SciCom\examples\not_so.rb:533
EOT

body(<<-EOT)
In this example, we try to call method .pp on a nil (empty) object and this method is not
defined.  In order to fix this, we can either prevent an empty trajectories class to be created,
or make sure that method show will not choke on the empty object.  We will take the second 
alternative, to follow SS4 and will check if either @times or @matrix are empty.  If either one
of them is nil, then we will print a message saying so. 

Although the first alternative, i.e., not allow for empty objects is a possibility in Ruby, 
it seems that this is not the case for S4.
EOT

code(<<-EOT)
class Trajectories

  def show
    if (@times.nil? || @matrix.nil?) 
      puts("*** Class Trajectories is empty!! *** ")
      return
    end
    puts("*** Class Trajectories, method Show *** ")
    Kernel.print("times = ")
    @times.pp
    nrow_show = [10, @matrix.nrow.gz].min
    ncol_show = R.min(10, @matrix.ncol).gz
    puts("* Traj (limited to a matrix 10x10) = ")
    @matrix[(1..nrow_show), (1..ncol_show)].format(digits: 2, nsmall: 2).pp
    puts("******* End Show (trajectories) ******* ")
  end
  
end
EOT

console(<<-EOT)
empty_traj.show
EOT

subsection("Method count_missing")

body(<<-EOT)
In R, methods 'print' and 'show' are methods that already exist.  SS4 wants to add a method 
called 'countMissing' which does not exist in R, and thus requires some special preparation. In
Ruby, every method we've created is a new method that exists inside the class.  The fact that
'print' happens to be also a method for class Kernel and 'show' is not, is not of special interest.
Actually we've seen that in order to call method print from the Kernel class we had to call 
Kernel.print.

To create method 'count_missing' we just need to reopen the Trajectories class and add the 
method the same way we've done with method 'show'. Again, let's first look at R's 'countMissing'
and then at Ruby's:
EOT

comment_code(<<-EOT)
> setMethod(
+ f= "countMissing",
+ signature= "Trajectories",
+ definition=function(object){
+ return(sum(is.na(object@traj)))
+ }
+ )
EOT

body(<<-EOT)
Here we introduce another particular case of SciCom.  R has many methods that have a '.' in 
there names, such as 'is.na'.  In Ruby, the dot '.' is has a special meaning as it is the way
we call a method on an object.  Doing 'R.is.na' will not work.  So, in SciCom, R functions that
have a dot in then will have the dot substituted by '__'.  So, method is.na in SciCom, becomes 
R.is__na.  In method count_missing we use method chaining and convert the final count to a number.
EOT

code(<<-EOT)
class Trajectories

  def count_missing
    return @matrix.is__na.sum.gz
  end

end
EOT

console(<<-EOT)
puts trajCochin.count_missing
EOT

subsection("To See the Methods")

body(<<-EOT)
In order to see the methods we have defined so far, we call call on class Trajectories the method
'instace_method' passing it one argument, 'false', as follows:
EOT

console(<<-EOT)
puts Trajectories.instance_methods(false)
EOT

body(<<-EOT)
It is interesting to observe that we see our three methods 'count_missing', 'print' and 'show', but
we also see two other methods 'times' and 'matrix', but those last two as far as we know are 
just instance variables and not methods, right? More on that when we talk about Accessors.

SciCom and Ruby, do not by default provide a way to see a method's code.  However, if the user uses
a Ruby console such as Pry, then seeing methods and debugging is possible.  Pry, is beyond the
scope of this document.
EOT

section("Construction")

body(<<-EOT)
Every class in Ruby has a constructor, if not explicitly defined, at least implicitly.  Method
initialize is the constructor method and the one that coordinates the whole construction process.
EOT

subsection("Inspector")

body(<<-EOT)
There is no default 'inspector' in Ruby as is R, although there is nothing that prevents the 
developer to inspect and validate the imput. For example, in the object Trajectories, one may 
want to check that the number of elements in 'times' is equal to the number of columns in 'matrix'
and if they are not, issue an error.  In order to understand why this is restriction, the user is
again directed to SS4.

Here we show the R code for this validation:
EOT

comment_code(<<-EOT)
> setClass(
+ Class="Trajectories",
+ representation(times="numeric",traj="matrix"),
+ validity=function(object){
+ cat("~~~ Trajectories: inspector ~~~ \n")
+ if(length(object@times)!=ncol(object@traj)){
+ stop ("[Trajectories: validation] the number of temporal measurements does not correspond
+ }else{}
+ return(TRUE)
+ }
+ )
EOT

body(<<-EOT)
In order to implement this validation we will coordinate it in the initialize method.
EOT

code(<<-EOT)
class Trajectories

  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix

    # validate the input, to make sure that size of @times and the number of columns in
    # @matrix are the same
    puts ("~~~ Trajectories: inspector ~~~ ")
    raise "[Trajectories: validation] the number of temporal measurements does not correspond with the number of columns in the matrix" if (@times.length.gz != @matrix.ncol.gz)

    # show the object just created
    show
    
  end

end

EOT

body(<<-EOT)
Let's first create a Trajectories that validades fine, i.e., the number of elements in @times is
equal to the number of columns of the matrix.  In this case, we will show a message saying that
validation was done and then print the object.
EOT

console(<<-EOT)
ok = Trajectories.new(times: R.c(1..2), matrix: R.matrix((1..2), ncol: 2))
EOT

body(<<-EOT)
Now, if we try to create a Trajectories that does not pass the validation criteria, our code 
will raise an exception.  Exceptions are a standard way to deal with errors in Ruby code and 
many other object oriented languages.  The interested reader should look for further documentation
on exception in the web.
EOT

console_error(<<-EOT)
error = Trajectories.new(times: R.c(1..3), matrix: R.matrix((1..2), ncol: 2))
EOT

body(<<-EOT)
The validation above does not consider the case when an empty object is created.  Here we will
check to see if either times or matrix are nil, if either one of them is nil, then we will raise
an exception and interrupt the creation of the object.  We also create a method validate that is
called from our initialize method.

Method validate has some interesting features about the integration of SciCom and R.  First, 
observe that instead of using @times.length.gz and @matrix.ncol.gz to get the length and number of
columns of variables 'times' and 'matrix' we actually compared (@times.length != @matrix.ncol). 
In this case, the actual R operator '!=' is being used.  This operator works on vectors and 
matrices and returns a logical vector with TRUE or FALSE.  In order to convert the logical vector,
with one element, to a logical value in Ruby we use method 'gt' (get truth).

EOT

code(<<-EOT)
class Trajectories

  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix

    # call method validate to validate our imput
    validate

    # show the object just created
    show
    
  end

  def validate

    # Let's first check that we do not have an empty object
    raise "Neither times nor matrix can be an empty object" if (@times.nil? || @matrix.nil?)
    
    # validate the input, to make sure that size of @times and the number of columns in
    # @matrix are the same
    puts ("~~~ Trajectories: inspector ~~~ ")
    raise "[Trajectories: validation] the number of temporal measurements does not correspond with the number of columns in the matrix" if (@times.length != @matrix.ncol).gt
    
  end

end
EOT

body(<<-EOT)
Let's try then creating an empty object:
EOT

console_error(<<-EOT)
error = Trajectories.new
EOT

body(<<-EOT)
Another example:
EOT

console_error(<<-EOT)
error = Trajectories.new(times: 1)
EOT

body(<<-EOT)
Let's see now that the implementation is correct and that it does not raise an error on valid 
input:
EOT

console(<<-EOT)
ok = Trajectories.new(times: R.c(1, 2), matrix: R.matrix((1..2), ncol: 2))
EOT

body(<<-EOT)
The 'initialize' method is called ONLY during the initial creation of the object. If any instance
variable is later modified, no control is done. At this moment though, there is no way to change
the value of any of our instance variables.
EOT

console_error(<<-EOT)
error.times = R.c(1, 2, 3)
EOT

body(<<-EOT)
The Trajectories class works for R objects and not for Ruby objects and thus expects as input R
objects.  Passing R objects in all examples has being the oblication of the programmer.  SciCom,
however, can translate Ruby objects to R objects and does so for parameter passing.  Here we do
an explicit convertion of Ruby object to R in class Trajectories by calling R.convert for our
input parameters
EOT

comment_code(<<-EOT)
class Trajectories

  def initialize(times: nil, matrix: nil)
    @times = R.convert(times)
    @matrix = R.convert(matrix)

    # call method validate to validate our imput
    validate

    # show the object just created
    show
    
  end

  def validate

    # Let's first check that we do not have an empty object
    raise "Neither times nor matrix can be an empty object" if (@times.nil? || @matrix.nil?)
    
    # validate the input, to make sure that size of @times and the number of columns in
    # @matrix are the same
    puts ("~~~ Trajectories: inspector ~~~ ")
    raise "[Trajectories: validation] the number of temporal measurements \#{@times.length.gz} \
does not correspond with the number of columns in the matrix \#{@matrix.ncol.gz}" if (@times.length.gz != @matrix.ncol.gz)
    
  end

end
EOT

class Trajectories

  def initialize(times: nil, matrix: nil)
    @times = R.convert(times)
    @matrix = R.convert(matrix)

    # call method validate to validate our imput
    validate

    # show the object just created
    show
    
  end

  def validate

    # Let's first check that we do not have an empty object
    raise "Neither times nor matrix can be an empty object" if (@times.nil? || @matrix.nil?)
    
    # validate the input, to make sure that size of @times and the number of columns in
    # @matrix are the same
    puts ("~~~ Trajectories: inspector ~~~ ")
    raise "[Trajectories: validation] the number of temporal measurements #{@times.length.gz} \
does not correspond with the number of columns in the matrix #{@matrix.ncol.gz}" if (@times.length.gz != @matrix.ncol.gz)
    
  end

end

body(<<-EOT)
And now let's create a new Trajectories, but we will now pass a Ruby range for times:
EOT

console(<<-EOT)
ok = Trajectories.new(times: (1..2), matrix: R.matrix((1..2), ncol: 2))
EOT

body(<<-EOT)
Perfect! This works fine.  Let's do another example... SciCom integrates with another Ruby
Gem called MDArray.  MDArray provides multi-dimensional arrays for Ruby similar to what is
find in NumPy.  It is beyond the scope of this paper to explain MDArray and the interested
reader is directed to MDArray wiki pages: https://github.com/rbotafogo/mdarray/wiki.
EOT

console(<<-EOT)
ok = Trajectories.new(times: (1..2), matrix: MDArray.double([2, 2], [1, 2, 3, 4]))
EOT

body(<<-EOT)
We will now create a multi-dimensional array with the help of MDArray. We could think of this
multi-dimensional array as having BMI data for multiple patients.  In this example, we have then
data for two patients:
EOT

code(<<-EOT)
multi_array = MDArray.fromfunction("double", [2, 3, 4]) { |x, y, z| x + y + z }
EOT

console(<<-EOT)
multi_array.print
EOT

body(<<-EOT)
But for our Trajectories class, we need data for only one patient at the time, so we cannot 
give this MDArray to Trajectories.  MDArray allow us to get data slices efficiently, that is,
it will not do a data copy, just manipulate indexes so that only a 'view' of the data is made
available.  So, let's make a Trajectories with data from our first patient:
EOT

console(<<-EOT)
ok1 = Trajectories.new(times: (1..4), matrix: multi_array.slice(0, 0))
EOT

body(<<-EOT)
And now let's create a Trajectories for our second patient: 
EOT

console(<<-EOT)
ok2 = Trajectories.new(times: (1..4), matrix: multi_array.slice(0, 1))
EOT

subsection("The Initializator")

body(<<-EOT)
As we have seen, method 'initialize' is the main object creator orchestrator.  This method can be
as complex as needed.  So, let's get on with some improvements to our Trajectories class.

It would be rather pleasant that the columns of the matrix of the trajectories have names, the 
names of measurements times. In the same way, the lines could be subscripted by a number of 
individual.

To do this in R, one also uses method initialize:
EOT

comment_code(<<-EOT)
> setMethod(
+ f="initialize",
+ signature="Trajectories",
+ definition=function(.Object,times,traj){
+ cat("~~~ Trajectories: initializator ~~~ \n")
+ colnames(traj) <- paste("T",times,sep="")
+ rownames(traj) <- paste("I",1:nrow(traj),sep= "")
+ .Object@traj <- traj # Assignment of the slots
+ .Object@times <- times
+ return(.Object) # return of the object
+ }
+ )
EOT

body(<<-EOT)
Let's do this change to our 'initialize' method; however, before that, we need to introduce
a new characteristic of SciCom.  In R, it is possible to assign a value to the result of a 
function.  For example, 'rownames(x) <- c("v1", "v2", "v3")'.  Assigning to functions that way
is not possible in Ruby.  In order to do this assignment we need to introduce method 'fassign'.
The above assignment is then writen in SciCom as 'x.fassign(:rownames, R.c("v1", "v2", "v3")),
where the first argument to function fassign is the function name preceded by ':'.
EOT

code(<<-EOT)
class Trajectories

  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix

    # call method validate to validate our imput
    validate

    # Add row  names
    puts ("~~~ Trajectories: initializator ~~~ ")
    @matrix.fassign(:colnames, R.paste("T", @times, sep: ""))
    @matrix.fassign(:rownames, R.paste("I", (1..@matrix.nrow.gz), sep: ""))

    # show the object just created
    show
    
  end

end
EOT

console(<<-EOT)
traj = Trajectories.new(times: R.c(1,2,4,8), matrix: R.matrix((1..8),nrow: 2))
EOT

body(<<-EOT)
Another example:
EOT

console_error(<<-EOT)
error = Trajectories.new(times: R.c(1,2,4,8), matrix: R.matrix((1..8), nrow: 2))
EOT

body(<<-EOT)
Note that we still call our 'validate' method and it is still an error to create an empty 
Trajectories or one in which the sizes are wrong:
EOT

console_error(<<-EOT)
error = Trajectories.new(times: R.c(1, 2, 48), matrix: R.matrix((1..8), nrow: 2))
EOT

body(<<-EOT)
A constructor does not necessarily take the instance variable of the object as argument. For
example, if we know (that is not the case in reality, but let us imagine so) that the
BMI increases by 0.1 every week, we could build trajectories by providing the number
of weeks and the initial weights.  

First the code in R, we skip the definition of class TrajectoriesBis:
EOT

comment_code(<<-EOT)
> setMethod ("initialize",
+ "TrajectoriesBis",
+ function(.Object,nbWeek,BMIinit){
+ traj <- outer(BMIinit,1:nbWeek,function(init,week){return(init+0.1*week)})
+ colnames(traj) <- paste("T",1:nbWeek,sep="")
+ rownames(traj) <- paste("I",1:nrow(traj),sep="")
+ .Object@times <- 1:nbWeek
+ .Object@traj <- traj
+ return(.Object)
+ }
+ )
EOT

body(<<-EOT)
Now, let's make a TrajectoriesBis in SciCom.  Here again, we should point out some characteristics
of our code:

* We made initialize with two positional arguments, instead of named arguments, i.e., the first
argument is the number of weeks and the second bmi_init.  Is this case, when making a new object the
position of the arguments is important and there is no way to pass the argument by name;
* R function outer was called as if a method from bmi_init using dot notation, although one could
use R.outer without problem;
* Function 'outer' expects an R function as its 3rd argument.  In order to build an R function from
SciCom, we need to pass the function definition as a string to R.eval.
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_reader :times
  attr_reader :matrix

  def initialize(number_weeks, bmi_init)
    @matrix = bmi_init.outer((1..number_weeks), 
                             R.eval("function(init, week) {return(init + 0.1 * week)}"))
    @times = number_weeks
  end
  
end

traj_bis = TrajectoriesBis.new(4, R.c(16,17,15.6))
EOT

console(<<-EOT)
traj_bis.matrix.pp
EOT

body(<<-EOT)
Is is always possible to pass a Ruby variable to any string, by interpolating it into the string.
To interpolate a variable into a string we put the variable inside #{}.  As an example, let's 
assume that we will also require the BMI increase as a parameter for the constructor:
EOT

comment_code(<<-EOT)
class TrajectoriesBis

  def initialize(number_weeks, bmi_init, increment)
    @matrix = bmi_init.outer((1..number_weeks), 
                             R.eval("function(init, week) {return(init + \#{increment} * week)}"))
    @times = number_weeks
  end
  
end

traj_bis = TrajectoriesBis.new(4, R.c(16,17,15.6), 0.3)
EOT

#code(<<-EOT)
class TrajectoriesBis

  def initialize(number_weeks, bmi_init, increment)
    @matrix = bmi_init.outer((1..number_weeks), 
                             R.eval("function(init, week) {return(init + #{increment} * week)}"))
    @times = number_weeks
  end
  
end

traj_bis = TrajectoriesBis.new(4, R.c(16,17,15.6), 0.3)
#EOT

console(<<-EOT)
traj_bis.matrix.pp
EOT

subsection("Constructors for Users")

body(<<-EOT)
Many times, it is interesting to have different ways of constructing an object depending on 
what information our users have or want to provide to the constructor.  Although we have only one 
initialize method, we can create multiple methods, that do some preprocessing and then call the 
initialize method to carry out the object building.

In order to do that, we use what are called class methods, instead of instance methods.  all the
methods we've created so far are instance methods, class methods are defined by prepending the 
self keyword to the methods name.  Still using the assumption that the BMI will grow by 0.1 per
week, let's define a regular trajectory without having to define a TrajectoriesBis as above:
EOT

comment_code(<<-EOT)
> regularTrajectories <- function(nbWeek,BMIinit) {
+ traj <- outer(BMIinit,1:nbWeek,function(init,week){return(init+0.1*week)})
+ times <- 1: nbWeek
+ return(new(Class="Trajectories",times=times,traj=traj))
+ }
> regularTrajectories(nbWeek=3,BMIinit=c(14,15,16))
EOT

body(<<-EOT)
Notice how method 'regular' is defined as 'self.regular', making it a class method.  The last
statement of the method definition is actually a call to the Trajectories contructor 'new' passing
the calculated values for times and matrix.

Notice also how method regular is called, similar to the way new is called by adding it after class
Trajectories name: 'Trajectories.regular'. 
EOT

code(<<-EOT)

class Trajectories

  def self.regular(number_weeks: nil, bmi_init: nil)
    matrix = bmi_init.outer((1..number_weeks),
                            R.eval("function(init, week) {return(init + 0.1 * week)}"))
    times = R.c((1..number_weeks))
    Trajectories.new(times: times, matrix: matrix)
  end
  
end

EOT

console(<<-EOT)
regular = Trajectories.regular(bmi_init: R.c(14, 15, 16), number_weeks: 3)
EOT

body(<<-EOT)
We have already seen that constructors can be as complex as needed, calling other methods and doing
calculations on the received parameters.  On this last example, we will check if the times 
variable was provided. If it is not provided, then we will use matrix columns to define the times:
EOT

code(<<-EOT)

class Trajectories

  def self.init(times: nil, matrix: nil)
    times = R.c((1..matrix.ncol.gz)) if times.nil?
    Trajectories.new(times: times, matrix: matrix)
  end

end
    
EOT

console(<<-EOT)
traj = Trajectories.init(matrix: R.matrix((1..8), ncol: 4))
EOT

section("Accessors")

body(<<-EOT)
Accessors are methods for getting and setting the value of instance variables.  
EOT

subsection("Get")

body(<<-EOT)
Getters are methods for getting the value of an instance variable.  We have being using getters
since the beginning of this document, without explicitly saying so.  When defining attr_reader 
:times and attr_reader :matrix, we have actually defined two getter methods for reading the values
of variables times and matrix respectively.  We can however define getters expicity:
EOT

code(<<-EOT)

class TrajectoriesBis

  def initialize(times: times, matrix: matrix)
    @times = times
    @matrix = matrix
  end
  
  def times
    @times
  end

  def matrix
    @matrix
  end
  
end

traj = TrajectoriesBis.new(times: 1, matrix: 2)

EOT

console(<<-EOT)
puts traj.times
EOT

console(<<-EOT)
puts traj.matrix
EOT

body(<<-EOT)
It is also possible to define more sophisticated  getters. For example one can
regularly need the BMI at inclusion.  In R, one would index a matrix as matrix[,1].  In Ruby,
it is a syntax error to have a ',' just after the '['.  In this case we need to add 'nil' as
in matrix[nil, 1]:
EOT

code(<<-EOT)
class Trajectories

  def get_traj_inclusion
    @matrix[nil, 1]
  end
  
end
EOT

console(<<-EOT)
trajCochin.get_traj_inclusion.pp
EOT

subsection("Set")

body(<<-EOT)
A setter is a method that assigns a value to a variable.  As with getters, Ruby also provides an
easy way to write setters and allow you to also write them explicitly.  Let's first use the 
simple way:
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_writer :times
  attr_writer :matrix
  
end

traj = TrajectoriesBis.new
traj.times = R.c(1, 2)
traj.matrix = R.matrix((1..2), ncol: 2)
EOT

console(<<-EOT)
traj.matrix.pp
EOT

body(<<-EOT)
Note that now we can use '=' to assign a value to both variables times and matrix. Without 
setters, changing the value of variables times and matrix was not possible.  Our class, up
to this point was protected from any changes to those variables.  If we need to allow changes
to those variable, then setters are needed.  In this case, the simple setter as shown above is
not ideal, since it would allow changes that break the restriction that variable times has to
have the same length as the number of columns of matrix.  In order to do the verification we
need to implement a more sophisticated setter.  In the example bellow, we add the 'times=' setter
that receives as input one argument.  First we convert the given argument to an R object, then
check to see that the length of times is the same as the number of columns and if everything is
fine, then we set the value of instance variable times:
EOT

#
# We need to put the times= definiton inside the comment_code block because it accesses a variable
# from inside the HereDoc.  If we do not comment this access we will get an error saying that
# @matrix is not a global variable, which is really the case.
#
comment_code(<<-EOT)
class Trajectories

  def times=(times)
    times = R.convert(times)
    raise "[Trajectories: validation] the number of temporal measurements \#{times.length.gz} \
does not correspond with the number of columns in the matrix \#{@matrix.ncol.gz}" if (times.length.gz != @matrix.ncol.gz)
    @times = times
  end
  
end
EOT

class Trajectories

  def times=(times)
    times = R.convert(times)
    raise "[Trajectories: validation] the number of temporal measurements #{times.length.gz} \
does not correspond with the number of columns in the matrix #{@matrix.ncol.gz}" if (times.length.gz != @matrix.ncol.gz)
    @times = times
  end
  
end

console_error(<<-EOT)
trajCochin.times = (1..5)
EOT

body(<<-EOT)
We now set the value approprietaly and will not get any errors:
EOT

console(<<-EOT)
trajCochin.times = R.c(1, 5, 6, 8)
EOT

subsection("The Operator '['")

body(<<-EOT)
It is also possible to define getters by using the operator '['.  This operator is not usually
used for returning instance variables and it is preferrable to use the methods we've used above;
however, for completeness with SS4 we are showing how to define this here.  Operator '[' is 
better left to be used for array/matrix indices. 
EOT

code(<<-EOT)

class Trajectories

  def [](var_name)
    
    case var_name
    when "times"
      @times
    when "matrix"
      @matrix
    else
      raise "Unknown instance variable"
    end
    
  end
  
end

EOT

console(<<-EOT)
trajCochin["times"].pp
EOT

body(<<-EOT)
Similarly, we could use operator '[]=' to assin a value to times and matrix.  We will not do this
here as we think that the other options are better and the interested user can easily find help,
if needed to implement such method.
EOT

section("To Go Further")

body(<<-EOT)
This section will introduce advance features of Object Oriented programming such as Inheritance 
and Modules and will also show some aspects of S4 that do not apply to Ruby.
EOT

subsection("Methods Using Serveral Arguments")

body(<<-EOT)
In Ruby, methods can have as many arguments as needed and those methods are defined the way we
have already seen in many of the examples above.  The example in SS4 presents a method that prints
different output if its input is numeric, character has both.  Let's write a class in Ruby that
does the same for Numeric and String.  In Ruby we do not define global functions, we always define
methods inside classes or modules (as we will see later).  Also, Ruby is not typed, so methods are
not called depending on their types as in SS4 examples.  Bellow, method test will be called with
one paramenter.  At the time of calling we do not know the type of the argument, the method can
then check is the received argument is a Numeric or a String and at this time, decide what should
be printed. 
EOT

class Test

  def test(input)

    case input
    when Numeric
      puts "The input is numeric: #{input}"
    when String
      puts "The input is a string: #{input}"
    else
      puts "The input is neither a number nor a string"
    end
    
  end
  
end

t = Test.new

comment_code(<<-EOT)
class Test

  def test(input)

    case input
    when Numeric
      puts "The input is numeric: \#{input}"
    when String
      puts "The input is a string: \#{input}"
    else
      puts "The input is neither a number nor a string"
    end
    
  end
  
end

t = Test.new

EOT


console(<<-EOT)
puts t.test(5)
EOT

console(<<-EOT)
puts t.test("Hello")
EOT

body(<<-EOT)
Ruby has ways of dealing with multiple arguments, missing arguments, undefined number of arguments,
named arguments, unnamed arguments, etc.  This is beyond the scope of this document and we 
suggest the interested reader to go to the many resources about Ruby that can easily be found 
on the web.

We will now create a new class 'Partition' that we will use later in this document.  This class will
have only the basic methods needed for the examples to work.
EOT

code(<<-EOT)
class Partition

  attr_reader :nb_groups
  attr_reader :part

  def initialize(nb_groups, part)
    @nb_groups = nb_groups
    @part = part
  end
  
end

partCochin = Partition.new(2, R.c("A","B","A","B").factor)
partStAnne = Partition.new(2, R.c("A","B").rep(R.c(50,30)).factor)

EOT

console(<<-EOT)
partCochin.part.pp
EOT

console(<<-EOT)
partStAnne.part.pp
EOT

body(<<-EOT)
We will suppose that part is always composed of capital letters going from A to
LETTERS[nb_groups].
EOT

subsection("Inheritance")

body(<<-EOT)
Ruby being a powerful Object Oriented language has the concept of Inheritance, but it does not 
allow for multiple inheritance.  Multiple inheritance has many drawbacks and Ruby just does not
support it.  However, Ruby has other concepts that make up for the lack or multiple inheritance as
we will see in the following examples.

So, let's go back to SS4 examples.  We want now to define a class called TrajPartitioned that 
inherits from class Trajectories.  When a class has a parent, all methods available for the 
parent are also available to the child.
EOT

code(<<-EOT)
class TrajPartitioned < Trajectories

  attr_reader :list_partitions

end
EOT

body(<<-EOT)
Thats all there is to it!  We've just created a class TrajPartitioned that inherits all methods
from class Trajectories and at this point does nothing different from Trajectories, but adds a 
new instance variable: list_partitions.

Creating TrajPartitioned without arguments will generate an error, since a Trajectories requires 
both times and matrix to be non null.
EOT

console_error(<<-EOT)
tdPitie = TrajPartitioned.new
EOT

body(<<-EOT)
Let's try to create a TrajPartitioned, but passing to it two partitions.  For that, let's first
create a new Partition:
EOT

code(<<-EOT)
partCochin2 = Partition.new(3, R.c("A", "C", "C", "B").factor)
EOT

body(<<-EOT)
And now let's create the TrajPartitioned:
EOT

console_error(<<-EOT)
tdCochin = TrajPartitioned.new(times: R.c(1,3,4,5), matrix: trajCochin.matrix, 
                               list_partitions: R.list(partCochin,partCochin2))
EOT

body(<<-EOT)
This didn't work giving us an error saying that <Partition...> is an unknown parameter for R. Hummm??
R function 'list' expects R objects, and in this case, partCochin and partCochin2 are Ruby classes,
so trying to apply function list to then does not work.  Clearly, we will have to work in the realm
of Ruby to keep the list of partitions.  This is not a problem as Ruby has data strucutres to 
maintain a list of objects, the Array.  Let's then try another solution:
EOT

console_error(<<-EOT)
tdCochin = TrajPartitioned.new(times: R.c(1,3,4,5), matrix: trajCochin.matrix, 
                               list_partitions: [partCochin, partCochin2])
EOT

body(<<-EOT)
We now get a second error: 'unknown keyword: list_partitions'.  Class TrajPartitioned inherits
from class Trajectories and class Trajectories has an initialize function that requires two 
parameters, times and matrix; list_partitions is not a parameter for initialize and is thus 
unknown.  In order to fix this problem we need to create an initialize method for class 
TrajPartitioned.
EOT

subsection("The 'super' Keyword")

body(<<-EOT)
R has a method called 'callNextMethod' for control flow between inherited classes.  In Ruby, we 
have a model that is a bit different.  When a method is called on a subclass, if this method is
not found it will be searched in the parent class and it will go up the hierarchy of classes until
it is found or an error is issued.  If we want the parent method to be called we can call 'super':
EOT

code(<<-EOT)
class TrajPartitioned
  
  def initialize(times: times, matrix: matrix, list_partitions: list_partitions)
    super(times: times, matrix: matrix)
    @list_partitions = list_partitions
  end
  
end
EOT

body(<<-EOT)
Let's try our example again:
EOT

console(<<-EOT)
tdCochin = TrajPartitioned.new(times: R.c(1,3,4,5), matrix: trajCochin.matrix, 
                               list_partitions: [partCochin, partCochin2])
EOT

body(<<-EOT)
Now tdCochin is created correctly; however, the 'show' method only shows information about 
times and matrix, there is nothing about our new list_partitions variable.  This is so, since
there is no method 'show' in TrajPartitioned, so method 'show' from Trajectories is executed.

So, let's start by writing a 'print' method, that will print all the information we have in 
TrajPartitioned.  The flow of control for this method is: Ruby see a call to 'print', so it checks
to see if 'print' is a method for TrajPartitioned.  Since we have just defined this method, Ruby
finds it and executes it.  The first command in print is a call to 'super', which will call the 
parent 'print' method, that print information for 'times' and 'matrix'.  When the parent 'print' 
finishes control continues after the 'super' call, printing the number of available partitions. 
EOT

class TrajPartitioned

  def print
    super
    puts ("the object also contains #{@list_partitions.length} partition")
    puts ("***** Fine of print (TrajPartitioned) *****")
  end
  
end

comment_code(<<-EOT)
class TrajPartitioned

  def print
    super
    puts ("the object also contains \#{@list_partitions.length} partition")
    puts ("***** Fine of print (TrajPartitioned) *****")
  end
  
end
EOT

console(<<-EOT)
tdCochin.print
EOT

body(<<-EOT)
Notice that this model is much cleaner than 'callNextMethod' and is not subject to any of the 
difficulties presented in SS4 and there is no need for the keywords “is”, “as” and “as<-”, although
Ruby provides methods to check the class of an object its hierarchy, etc. when needed.

In Ruby there is no similar method as "setIs" and it is not possible to convert one class into 
another, but there are other ways of getting the necessary results.  Let's then implement a 
method that returns the partition with the least number of groups.  First, as usual, the R code
with 'setIs':
EOT

comment_code(<<-EOT)
> setIs(
+ class1="TrajPartitioned",
+ class2="Partition",
+ coerce=function(from,to){
+ numberGroups <- sapply(tdCochin@listPartitions,getNbGroups)
+ Smallest <- which.min(-numberGroups)
+ to<-new("Partition")
+ to@nbGroups <- getNbGroups(from@listPartitions[[Smallest]])
+ to@part <- getPart(from@listPartitions[[Smallest]])
+ return(to)
+ }
+ )
EOT


body(<<-EOT)
And now the Ruby code.  Here we are getting deeper into Ruby and it is becoming harder for a
pure R developer to understand the code.  We will describe it in more detail:

* We define a method called 'to_part' that has one argument 'which'.  By default 'which' is 
':min', the name of the minimum method.  This means that if no argument is given to to_part it
will assume the which = :min;
* @list_partition is a Ruby array.  Method map is similar to method sapply in R, it applies a
'block' to every element of the array, returning an array.  Describing blocks is beyond the 
scope of this document, but we can think of it as if it were a function.  
The block is in '{}' and has one argument named 'part'.  Thus, map goes through all elements 
of the array, and gets the nb_groups of the element and returns them into the number_groups array.
* number_groups is and array and doing number_groups.min returns
the minimum value in number_groups and number_groups.max the maximum.  We can call a method on an
object by 'sending' the method name to the object, so, number_groups.send(:min) is equivalent to
number_groups.min;
* Method 'index' for array, returns the index of a given element. So, number_groups(3) would return
the index of the element '3'.  Then number_groups.index(number_groups.min) returns the index of
the minimum element in the array.  This is the equivalent of R which.min(number_groups);
* Finally, number_groups.index(number_groups.send(which)), will return the index of the element we
ask for, be it :min or :max.  Note that if we pass another value, this would be an error.
EOT

code(<<-EOT)
class TrajPartitioned

  def to_part(which = :min)
    number_groups = @list_partitions.map { |part| part.nb_groups }
    selected = number_groups.index(number_groups.send(which))
    return @list_partitions[selected]
  end
  
end
EOT

body(<<-EOT)
To get the partition whith the minimum number of elements:
EOT

console(<<-EOT)
tdCochin.to_part.part.pp
EOT

body(<<-EOT)
To get the partition whith the maximum number of elements:
EOT

console(<<-EOT)
tdCochin.to_part(:max).part.pp
EOT



section("ET Phone Home")

code(<<-EOT)
class TrajPartitioned

  def to_part2
    R.pack = R.rpack(@list_partitions, scope: :internal)
    number_groups = R.eval("sapply(pack, function(x) x$run('nb_groups'))")
    @list_partitions[number_groups.which__min.gz]
  end
  
end
EOT


console(<<-EOT)
tdCochin.to_part2.part.pp
EOT
