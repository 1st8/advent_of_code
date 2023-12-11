#!/usr/bin/env ruby

require "test/unit"

class Image
  def self.parse(input)
    new(input.each_line.map do |l|
      l.strip.chars.map { (_1 == "#") ? true : nil }
    end)
  end

  attr_accessor :data

  def initialize(data)
    @data = data
  end

  def locations
    data.each_with_index.flat_map do |row, y|
      row.each_with_index.filter_map do |cell, x|
        cell.nil? ? nil : [y, x]
      end
    end
  end

  def expand
    2.times do
      self.data = data.each_with_index.flat_map do |row, i|
        if row.all?(&:nil?)
          [row, row]
        else
          [row]
        end
      end.transpose
    end
    self
  end

  def to_s
    data.map do |row|
      row.map { _1.nil? ? "." : "#" }.join
    end.join("\n")
  end
end

def part1(input)
  image = Image.parse(input).expand
  image.locations.combination(2).sum do |l1, l2|
    l1.zip(l2).sum { (_1 - _2).abs }
  end
end

def part2(input, mul = 1_000_000)
  image = Image.parse(input)
  empty_row_ids = image.data.each_with_index.filter_map do |row, y|
    y if row.all?(&:nil?)
  end
  empty_col_ids = image.data.transpose.each_with_index.filter_map do |col, x|
    x if col.all?(&:nil?)
  end
  image.locations.combination(2).sum do |l1, l2|
    l1y, l1x = l1
    l2y, l2x = l2
    range_y = Range.new(*[l1y, l2y].sort, true)
    range_x = Range.new(*[l1x, l2x].sort, true)
    exp_mul_y = (range_y.to_a & empty_row_ids)
    exp_mul_x = (range_x.to_a & empty_col_ids)

    (range_y.size + (mul - 1) * exp_mul_y.size) +
      (range_x.size + (mul - 1) * exp_mul_x.size)
  end
end

class TestSolution < Test::Unit::TestCase
  def input
    "...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."
  end

  def test_expand
    assert_equal("....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......", Image.parse(input).expand.to_s)
  end

  def test_locations
    assert_equal(
      [[0, 1], [1, 2]],
      Image.parse(
        ".#.
..#"
      ).locations
    )
  end

  def test_part1
    assert_equal(374, part1(input))
  end

  def test_part2
    assert_equal(1030, part2(input, 10))
    assert_equal(8410, part2(input, 100))
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
