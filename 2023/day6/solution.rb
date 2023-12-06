#!/usr/bin/env ruby

require "test/unit"

# Returns [time, distance] tuples
def parse(input)
  times, distances = input.strip.split("\n").map {
    _, *numbers = _1.split(/\s+/)
    numbers.map(&:to_i)
  }
  [times, distances].transpose
end

def part1(input)
  tuples = parse(input)
  tuples.map do |time, distance|
    time.times.select do |ms|
      (time - ms) * ms > distance
    end
  end.map(&:length).reduce(&:*)
end

def part2(input)
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

  # def test_part2
  #   assert_equal(46, part2(input))
  # end
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
