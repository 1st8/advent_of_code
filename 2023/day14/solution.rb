#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.each_line.map do |l|
    l.strip.chars
  end
end

def part1(input)
  data = parse(input)
  $col_count = data.first.length
  $row_count = data.length
  move_north(data)

  data.reverse.each_with_index.map do |row, i|
    row.count { _1 == "O" } * (i + 1)
  end.sum
end

def move_north(data)
  $col_count.times do |x|
    move = 0
    $row_count.times do |y|
      case data[y][x]
      when "O"
        data[y][x], data[y - move][x] = data[y - move][x], data[y][x]
      when "."
        move += 1
      when "#"
        move = 0
      else
        raise "wat"
      end
    end
  end
end

def move_west(data)
  $row_count.times do |y|
    move = 0
    $col_count.times do |x|
      case data[y][x]
      when "O"
        data[y][x], data[y][x - move] = data[y][x - move], data[y][x]
      when "."
        move += 1
      when "#"
        move = 0
      else
        raise "wat"
      end
    end
  end
end

def move_south(data)
  $col_count.times do |x|
    move = 0
    $row_count.times do |dy|
      y = $row_count - dy - 1
      case data[y][x]
      when "O"
        data[y][x], data[y + move][x] = data[y + move][x], data[y][x]
      when "."
        move += 1
      when "#"
        move = 0
      else
        raise "wat"
      end
    end
  end
end

def move_east(data)
  $row_count.times do |y|
    move = 0
    $col_count.times do |dx|
      x = $col_count - dx - 1
      case data[y][x]
      when "O"
        data[y][x], data[y][x + move] = data[y][x + move], data[y][x]
      when "."
        move += 1
      when "#"
        move = 0
      else
        raise "wat"
      end
    end
  end
end

def part2(input)
  data = parse(input)
  $col_count = data.first.length
  $row_count = data.length
  iterations = 1_000_000_000
  i = 0
  cycle_ids = {}
  skipped = false

  while iterations > i
    move_north(data)
    move_west(data)
    move_south(data)
    move_east(data)
    unless skipped
      if cycle_ids[data]
        loop_size = i - cycle_ids[data]
        skip_count = (iterations - i) / loop_size
        puts "Loop found: #{cycle_ids[data]} => #{i}; skipping #{skip_count} loops"
        i += skip_count * loop_size
        skipped = true
      else
        cycle_ids[data] = i
      end
    end
    i += 1
  end

  data.reverse.each_with_index.map do |row, i|
    row.count { _1 == "O" } * (i + 1)
  end.sum
end

class TestSolution < Test::Unit::TestCase
  def input
    "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"
  end

  def test_part1
    assert_equal(136, part1(input))
  end

  def test_part2
    assert_equal(64, part2(input))
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
