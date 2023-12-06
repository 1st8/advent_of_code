#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  times, distances = input.strip.split("\n").map {
    _, *numbers = _1.split(/\s+/)
    numbers.map(&:to_i)
  }
  [times, distances]
end

def part1(input)
  tuples = parse(input).transpose
  tuples.map do |time, distance|
    border = (find_border(distance, time) + 1).floor
    time - (border * 2) + 1
  end.reduce(&:*)
end

def part2(input)
  time, distance = parse(input).map { _1.map(&:to_s).join.to_i }
  border = (find_border(distance, time) + 1).floor
  time - (border * 2) + 1
end

def find_border(distance, time)
  Rational(1, 2) * (time - Math.sqrt(-4 * distance + time**2))
end

class TestSolution < Test::Unit::TestCase
  def input
    "Time:      7  15   30
Distance:  9  40  200
"
  end

  def test_part1
    assert_equal(288, part1(input))
  end

  def test_part2
    assert_equal(71503, part2(input))
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
