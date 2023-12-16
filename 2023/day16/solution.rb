#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.split("\n").map(&:chars)
end

def energize(data, start, vec)
  energized = Set.new
  shine(data, start, vec, energized)
  energized.map(&:first).uniq
end

def part1(input)
  data = parse(input)
  energize(data, [0, 0], [0, 1]).count
end

def shine(data, coords, vec, energized)
  return if coords.any?(&:negative?)
  return if coords.any? { _1 >= data.length || _1 >= data.first.length }
  return if energized.include?([coords, vec])

  energized << [coords, vec]

  if $debug
    data.each_with_index do |l, y|
      l.each_with_index do |c, x|
        if coords == [y, x]
          print "\e[31m#{c}\e[0m"
        elsif energized.any? { |energized_coords, _| energized_coords == [y, x] }
          print "\e[32m#{c}\e[0m"
        else
          print c
        end
      end
      puts
    end
    puts "\n\n"
  end

  case data.dig(*coords)
  when "."
    shine(data, step(coords, vec), vec, energized)
  when "|"
    if vec[1] != 0
      shine(data, step(coords, [1, 0]), [1, 0], energized)
      shine(data, step(coords, [-1, 0]), [-1, 0], energized)
    else
      shine(data, step(coords, vec), vec, energized)
    end
  when "-"
    if vec[0] != 0
      shine(data, step(coords, [0, 1]), [0, 1], energized)
      shine(data, step(coords, [0, -1]), [0, -1], energized)
    else
      shine(data, step(coords, vec), vec, energized)
    end
  when "/"
    # case vec
    # when [0, 1]
    #   [-1, 0]
    # when [0, -1]
    #   [1, 0]
    # when [1, 0]
    #   [0, -1]
    # when [-1, 0]
    #   [0, 1]
    # end
    x, y = vec
    vec = [-y, -x]
    shine(data, step(coords, vec), vec, energized)
  when "\\"
    # case vec
    # when [0, 1]
    #   [1, 0]
    # when [0, -1]
    #   [-1, 0]
    # when [1, 0]
    #   [0, 1]
    # when [-1, 0]
    #   [0, -1]
    # end
    x, y = vec
    vec = [y, x]
    shine(data, step(coords, vec), vec, energized)
  end
end

def step(coords, vec)
  coords.zip(vec).map(&:sum)
end

def part2(input)
  data = parse(input)
  max_y = data.length
  max_x = data.first.length
  energized_counts = max_y.times.flat_map do |y|
    [
      energize(data, [y, 0], [0, 1]).count,
      energize(data, [y, max_x], [0, -1]).count
    ]
  end
  energized_counts += max_x.times.flat_map do |x|
    [
      energize(data, [0, x], [1, 0]).count,
      energize(data, [max_y, x], [-1, 0]).count
    ]
  end
  energized_counts.max
end

class TestSolution < Test::Unit::TestCase
  def input
    '.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\\..
.-.-/..|..
.|....-|.\
..//.|....
'
  end

  def test_part1
    $debug = true
    assert_equal(46, part1(input))
    $debug = false
  end

  def test_part2
    assert_equal(51, part2(input))
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
