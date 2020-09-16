# First just an illustration of how `for` loops work

## You an iterate over any Enumerable (eg: Range, Array)

for i in (0..5)
  puts i
end

## You may also destructure nested Arrays

array = [['apple', 24], ['banana', 27]]

for fruit, quantity in array
  puts "#{fruit} => #{quantity}"
end

# The reason you'll often hear

## When you use `each`, you're creating a new scope:

(0..5).each do |i|
  new_var_1 = 'hello'
end

new_var_1 rescue nil # NameError

## But `for` doesn't work like that:

for i in (0..5)
  new_var_2 = 'hello'
end

new_var_2

## Isn't it strange we often take offense to this but don't want `if`, `while`,
## or other keywords to be rewritten?

### if

if true
  new_var_3 = 'hello'
end

new_var_3 # Accessible

### while

flag = true
while flag
  new_var_4 = 'hello'
  flag = false
end
new_var_4

### until

flag = false
until flag
  new_var_5 = 'hello'
  flag = true
end
new_var_5

### case

flag = false
case flag
when false then new_var_6 = 'hello'
end

new_var_6

class Object
  def if?
    yield if self
  end
end

new_var_3.if? do
  puts 'new if'
end

## You don't even need to use them:

if false
  new_var_7 = 'hello'
end

new_var_7 # Accessible

## Benchmark is cool

require 'benchmark'

Benchmark.bm(15) do |x|
  x.report("version_1") do
    # ...
  end

  x.report("version_2") do
    # ...
  end
end

## Why don't we make an `if?` method?

require 'benchmark'

var = true
n = 10000

Benchmark.bm do |x|
  x.report("if?") do
    n.times do
      var.if? { nil }
    end
  end

  x.report("if") do
    n.times do
      nil if var
    end
  end
end

## What about for?

n = 10000000
a = i

Benchmark.bmbm do |x|
  x.report("for") do
    for i in (0..n)
      a = i
    end
  end

  x.report("each") do
    (0..n).each do |i|
      a = i
    end
  end

  x.report("while") do
    i = 0
    while i < n
      a = i
      i += 1
    end
  end

  x.report("until") do
    i = 0
    until i == n
      a = i
      i += 1
    end
  end

  x.report("times") do
    n.times do |i|
      a = i
    end
  end

  x.report("upto") do
    0.upto(n) do |i|
      a = i
    end
  end
end

## Now that captures the idea of lots of iterations, but what about the
## cost of initiating a loop?

n = 1000
m = n * 10
a = i

Benchmark.bmbm do |x|
  x.report("for") do
    m.times do
      for i in (0..n)
        a = i
      end
    end
  end

  x.report("each") do
    m.times do
      (0..n).each do |i|
        a = i
      end
    end
  end

  x.report("while") do
    m.times do
      i = 0
      while i < n
        a = i
        i += 1
      end
    end
  end

  x.report("until") do
    m.times do
      i = 0
      until i == n
        a = i
        i += 1
      end
    end
  end

  x.report("times") do
    m.times do
      n.times do |i|
        a = i
      end
    end
  end

  x.report("upto") do
    m.times do
      0.upto(n) do |i|
        a = i
      end
    end
  end
end
