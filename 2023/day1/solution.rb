#!/usr/bin/env ruby

require "test/unit"

def part1(input)
  input.each_line.map do |l|
    left = l[/\d/, 0]
    right = l[/.*(\d).*?$/, 1]
    [left.to_i, right.to_i]
  end.sum { |l, r| l * 10 + r }
end

def part2(input)
  numbers = %w[one two three four five six seven eight nine].each_with_index.map { |s, i| [s, i + 1] }.to_h
  regex_l = /(\d|#{numbers.keys.join("|")})/
  regex_r = /.*(\d|#{numbers.keys.join("|")}).*?$/
  input.each_line.map do |l|
    left = l[regex_l, 1]
    left = /\d/.match?(left) ? left.to_i : numbers[left]
    right = l[regex_r, 1]
    right = /\d/.match?(right) ? right.to_i : numbers[right]
    [left, right]
  end.sum { |l, r| l * 10 + r }
end

class TestSolution < Test::Unit::TestCase
  def test_part1
    input = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
    assert_equal(142, part1(input))
  end

  def test_part2
    input = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"
    assert_equal(281, part2(input))
  end
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
