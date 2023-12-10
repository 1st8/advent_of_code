#!/usr/bin/env ruby

require "test/unit"

class Map
  CHARS = {
    "|" => {draw: "┃", connections: [:top, :bottom]},
    "-" => {draw: "━", connections: [:left, :right]},
    "L" => {draw: "┗", connections: [:top, :right]},
    "J" => {draw: "┛", connections: [:left, :top]},
    "7" => {draw: "┓", connections: [:bottom, :left]},
    "F" => {draw: "┏", connections: [:right, :bottom]},
    "." => {draw: " ", connections: []},
    "S" => {draw: "S", connections: [:top, :right, :bottom, :left]}
  }

  DIRECTIONS = {
    top: [-1, 0],
    right: [0, 1],
    bottom: [1, 0],
    left: [0, -1]
  }

  INVERSIONS = {
    top: :bottom,
    right: :left,
    bottom: :top,
    left: :right
  }

  attr_reader :data, :start

  def initialize(data)
    @data = data.each_with_index.map do |l, y|
      l.each_with_index.map do |c, x|
        @start = [y, x] if c == "S"
        CHARS.fetch(c)
      end
    end
    self.start_cell = start_cell.clone.merge(connections: filter_connectable(start_cell[:connections], @start))
  end

  def start_cell
    @data[@start[0]][@start[1]]
  end

  def start_cell=(cell)
    @data[@start[0]][@start[1]] = cell
  end

  def all_connected_to(coords)
    connections = data.dig(*coords, :connections)
    filter_connectable(connections, coords).map do |dir|
      coords.zip(DIRECTIONS[dir]).map(&:sum)
    end
  end

  def drawable
    data.map do |l|
      l.map { _1[:draw] }
    end
  end

  private

  def filter_connectable(connections, coords)
    y, x = coords
    connections.filter do |dir|
      cx, cy = [y, x].zip(DIRECTIONS[dir]).map(&:sum)
      [cx, cy] if data.dig(cx, cy, :connections).include?(INVERSIONS[dir])
    end
  end
end

def draw(data)
  data.each do |l|
    puts l.join(" ")
  end
end

def parse(input)
  Map.new(input.each_line.map do |l|
    l.strip.chars
  end)
end

def part1(input)
  map = parse(input)
  current = map.start
  count = 0
  visited = []
  loop do
    visited << current
    visited.shift if visited.size > 2
    current = (map.all_connected_to(current) - visited).compact.first
    count += 1
    break if current == map.start
  end
  (count / 2.0).ceil
end

def part2(input)
  map = parse(input)
  current = map.start
  visited = []
  loop do
    visited << current
    current = (map.all_connected_to(current) - visited.last(2)).compact.first
    break if current == map.start
  end

  visited_lookup = Set.new(visited)
  enclosed_count = 0

  map.data.each_with_index do |line, y|
    enclosed = Set.new
    line.each_with_index do |cell, x|
      if visited_lookup.include?([y, x])
        vertical = Set.new(cell[:connections]) & [:top, :bottom]
        enclosed = enclosed ^ vertical
      elsif enclosed.size > 0
        enclosed_count += 1
      end
    end
  end

  enclosed_count
end

class TestSolution < Test::Unit::TestCase
  def simple_input
    ".....
.S-7.
.|.|.
.L-J.
....."
  end

  def test_map
    assert_equal(
      [[1, 2], [2, 1]],
      parse(simple_input).all_connected_to([1, 1])
    )
  end

  def test_part1_1
    assert_equal(4, part1(simple_input))
  end

  def test_part1_2
    assert_equal(8, part1("..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ..."))
  end

  def test_part1_3
    assert_equal(8, part1("7-F7-
  .FJ|7
  SJLL7
  |F--J
  LJ.LJ"))
  end

  def test_part2
    assert_equal(4, part2("...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
"))
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
