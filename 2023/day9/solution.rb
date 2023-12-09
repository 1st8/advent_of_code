#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.each_line.map do |l|
    l.split(" ").map(&:to_i)
  end
end

def part1(input)
  parse(input).sum(&method(:extrapolate))
end

def extrapolate(numbers)
  sequences = [numbers]
  until sequences.last.all?(&:zero?)
    sequences << sequences.last.each_cons(2).map do |l, r|
      r - l
    end
  end
  sequences.last << 0
  sequences.reverse.each_cons(2) do |prev, curr|
    curr << curr.last + prev.last
  end
  sequences.first.last
end

def part2(input)
  parse(input).sum(&method(:extrapolate_backwards))
end

def extrapolate_backwards(numbers)
  sequences = [numbers]
  until sequences.last.all?(&:zero?)
    sequences << sequences.last.each_cons(2).map do |l, r|
      r - l
    end
  end
  sequences.last.unshift(0)
  sequences.reverse.each_cons(2) do |prev, curr|
    curr.unshift(curr.first - prev.first)
  end
  sequences.first.first
end

class TestSolution < Test::Unit::TestCase
  def input
    "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"
  end

  def test_extrapolate
    assert_equal(18, extrapolate([0, 3, 6, 9, 12, 15]))
  end

  def test_part1
    assert_equal(114, part1(input))
  end

  def test_extrapolate_backwards
    assert_equal(5, extrapolate_backwards([10, 13, 16, 21, 30, 45]))
  end

  def test_part2
    assert_equal(2, part2(input))
  end
end

def measure(label)
  require "benchmark"
  res = nil
  real = Benchmark.measure { res = yield }.real
  puts "%s: %s (took: %.4fms)" % [label, res.inspect, real * 1000]
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  measure("Part1") { part1(input) }
  measure("Part2") { part2(input) }
end
