#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  numbers = []
  symbols = []
  input.lines.each_with_index do |l, i|
    l.scan(/\d+/) do |n|
      x = Regexp.last_match.begin(0)
      numbers << {value: n.to_i, positions: n.length.times.map { [i, x + _1] }}
    end
    l.scan(/[^.\d\n]/) do |s|
      x = Regexp.last_match.begin(0)
      symbols << {value: s, position: [i, x]}
    end
  end
  [numbers, symbols]
end

def find_adjacent(numbers, symbol)
  sy, sx = symbol[:position]
  numbers.select do |number|
    number[:positions].any? do |y, x|
      (sy - y).abs <= 1 && (sx - x).abs <= 1
    end
  end
end

def part1(input)
  numbers, symbols = parse(input)
  part_numbers = symbols
    .flat_map { |symbol| find_adjacent(numbers, symbol) }
    .uniq
  part_numbers.sum { _1[:value] }
end

def part2(input)
  numbers, symbols = parse(input)
  gears = symbols
    .select { _1[:value] == "*" }
    .map { |symbol| find_adjacent(numbers, symbol) }
    .select { |gear_ratio| gear_ratio.length == 2 }
  gears.sum { _1[:value] * _2[:value] }
end

class TestSolution < Test::Unit::TestCase
  def input
    "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."
  end

  def test_part1
    assert_equal(4361, part1(input))
  end

  def test_part2
    assert_equal(467835, part2(input))
  end
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
