require 'benchmark'

## How define method works

class Something
  L = lambda { |s| :foo }

  [:foo, :bar].each do |m|
    define_method m do
      m
    end
  end

  def to_s
    :foo
  end

  def ival
    instance_eval(&L)
  end
end

puts Something.new.foo # 'foo'

## After creation, these methods are just like all others

something = Something.new

puts something.respond_to?(:foo) # true
puts something.foo # :foo
puts something.method(:foo) # Method
puts something.public_methods.include?(:foo) # true

## A quick benchmark of a defined method vs a normal method

n = 100000

Benchmark.bmbm(20) do |x|
  x.report("normal method") do
    n.times do
      something.to_s
    end
  end

  x.report("defined method") do
    n.times do
      something.foo
    end
  end

  x.report("instance_eval") do
    n.times do
      something.ival
    end
  end
end

### This roughly what you'll get with define_method

class Food
  L = lambda { |s| :foo }

  def foo
    instance_eval(&L)
  end
end

puts Food.new.foo

### ------------------ side quest

## Here are some methods from ObjectSpace

require 'objspace'

klass = Integer

ObjectSpace.count_objects_size # Count objects in bytes for each type

ObjectSpace.memsize_of_all(klass) # Consuming memory of all living objects

ObjectSpace.each_object(klass) { } # Yield each living object of class

## We can define a testing method

def count_nonreleased_bytes(klass)
  GC.start(full_mark: true, immediate_sweep: true)
  count = ObjectSpace.memsize_of_all(klass)
  yield
  GC.start(full_mark: true, immediate_sweep: true)
  diff = ObjectSpace.memsize_of_all(klass) - count
  puts "#{diff} bytes of unreleased #{klass}"
end

count_nonreleased_bytes(String) do
  str = '123'
end # 0

str = nil
count_nonreleased_bytes(String) do
  str = '123'
end

## You can access locals from inside of define_method

count_nonreleased_bytes(String) do
  class Greeter
    greeting = "ciao, "
    other_var = 'a' * 10000

    define_method :greet do |name|
      "#{greeting} #{name}"
    end
  end

  puts Greeter.new.greet('john')
end


## Sometimes we may mistakenly grab a hold of an object and not let go

count_nonreleased_bytes(File) do
  class User
    banned_user_file = File.open('/tmp/banned_users.txt')
    BANNED_USERS = banned_user_file.readlines

    [:foo, :bar].each do |method|
      define_method method do
        method
      end
    end
  end
end

## The same is true for normal calls to block methods

count_nonreleased_bytes(File) do

  class User
    def parse
      file = File.open('/tmp/banned_users.txt')
      add_callback { }
    end

    def add_callback(&block)
      @callbacks ||= []
      @callbacks << block
    end
  end

  user = User.new
  user.parse

end

## class-eval as an alternative

count_nonreleased_bytes(String) do
  class Food
    other_var = 'a' * 1000

    ['apple', 'pear'].each do |fruit|
      class_eval <<-STR
        def #{fruit}?
          true
        end
      STR
    end

    def orange?
      true
    end
  end
end

food = Food.new

Benchmark.bm do |x|
  x.report "normal method" do
    n.times do
      food.orange?
    end
  end

  x.report "class eval method" do
    n.times do
      food.apple?
    end
  end
end
