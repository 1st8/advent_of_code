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
    time.times.select do |ms|
      (time - ms) * ms > distance
    end
  end.map(&:length).reduce(&:*)
end

def part2(input)
  time, distance = parse(input).map { _1.map(&:to_s).join.to_i }
  time.times.count do |ms|
    (time - ms) * ms > distance
  end
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

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
