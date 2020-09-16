require 'benchmark'

## Here's how method_missing works:

class Something
  def method_missing(method)
    method.to_s.reverse
  end

  def to_s
    'hello'
  end
end

puts Something.new.john # nhoj

## Here's maybe a more practical use case:

class DotHash
  def initialize(hash)
    @hash = hash
  end

  def method_missing(m)
    @hash[m]
  end
end

dot_hash = DotHash.new(a: 2, b: 3)
puts dot_hash.a # 2

## By default method missing doesn't make respond_to? correct

puts dot_hash.respond_to?(:a) # false

class DotHash
  def respond_to?(m)
    @hash.key?(m)
  end
end

puts dot_hash.respond_to?(:a) # true
puts dot_hash.a # 2

begin
  dot_hash.method(:a)
rescue NameError
end

## We can fix that by defining respond_to_missing? instead

class DotHash
  def respond_to_missing?(m, include_private = false)
    @hash.key?(m)
  end
end

puts dot_hash.respond_to?(:a) # true
puts dot_hash.a # 2
puts dot_hash.method(:a) # Method
puts dot_hash.public_methods.include?(:a) # false

## Benchmark the lookups of method missing methods vs regular methods

n = 10000000

something = Something.new

Benchmark.bm do |x|
  x.report("respond_to real method") do
    n.times do
      something.respond_to?(:to_s)
    end
  end

  x.report("respond_to method_missing") do
    n.times do
      something.respond_to?(:a)
    end
  end
end

## Benchmark actually calling equivalent methods

class Something2
  def to_s
    'hello'
  end

  def method_missing(m)
    'hello'
  end
end

something = Something2.new

Benchmark.bm do |x|
  x.report("real method") do
    n.times do
      something.to_s
    end
  end

  x.report("method_missing") do
    n.times do
      something.a
    end
  end
end

# What does it look like to debug an issue that occurs inside of a method_missing

class Food
  def method_missing(m)
    raise 'error'
  end

  def respond_to_missing?(m, *a)
    true
  end
end

Food.new.apple
