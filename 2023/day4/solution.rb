#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.each_line.map do |l|
    _, have, winning = l.split(/: | \| /)
    [have, winning].map { _1.strip.split(/\s+/).map(&:to_i) }
  end
end

def part1(input)
  cards = parse(input)
  cards.sum do |have, winning|
    count = (have & winning).length
    (count > 0) ? 2.pow(count - 1) : 0
  end
end

def part2(input)
  cards = parse(input).map { |have, winning| {value: (have & winning).length, count: 1} }
  cards.each_with_index do |card, i|
    cards[(i + 1)...(i + 1 + card[:value])].each { _1[:count] += card[:count] }
  end
  cards.sum { _1[:count] }
end

class TestSolution < Test::Unit::TestCase
  def input
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"
  end

  def test_part1
    assert_equal(13, part1(input))
  end

  def test_part2
    assert_equal(30, part2(input))
  end
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
