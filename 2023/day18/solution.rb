#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.each_line.map do |l|
    direction, length, color = l.split(/[ ()]+/)
    {direction:, length: length.to_i, color:}
  end
end

def part1(input)
  data = parse(input)
  pos = [0, 0]
  dug = Set.new
  dug << pos
  data.each do |instruction|
    instruction[:length].times do |i|
      case instruction[:direction]
      when "R"
        pos = [pos[0], pos[1] + 1]
      when "D"
        pos = [pos[0] + 1, pos[1]]
      when "L"
        pos = [pos[0], pos[1] - 1]
      when "U"
        pos = [pos[0] - 1, pos[1]]
      end
      dug << pos
    end
  end

  min_y, max_y = dug.map { _1[0] }.yield_self { [_1.min, _1.max] }
  min_x, max_x = dug.map { _1[1] }.yield_self { [_1.min, _1.max] }
  y_range = (min_y..max_y)
  x_range = (min_x..max_x)

  start = [1, x_range.drop(1).find { |x| dug.include?([1, x - 1]) && !dug.include?([1, x]) }]
  queue = [start]
  filled = Set.new
  until queue.empty?
    current = queue.shift
    next if dug.include?(current) || filled.include?(current)

    y, x = current
    next if !x_range.include?(x) || !y_range.include?(y)

    filled << current

    queue.push([y + 1, x])
    queue.push([y - 1, x])
    queue.push([y, x + 1])
    queue.push([y, x - 1])
  end

  if $debug
    y_range.each do |y|
      x_range.each do |x|
        if start == [y, x]
          print "\e[32mX\e[0m"
        elsif filled.include?([y, x])
          print "\e[31m.\e[0m"
        elsif dug.include?([y, x])
          print "\e[31m#\e[0m"
        else
          print "."
        end
      end
      puts
    end
    puts "\n\n"
  end

  dug.size + filled.size
end

def part2(input)
  instructions = parse(input).map do |instruction|
    distance = instruction[:color].slice(1..5).to_i(16)
    direction = %w[R D L U][instruction[:color][-1].to_i]
    {distance:, direction:}
  end
  perimeter = instructions.sum { _1[:distance] }

  area = 0
  current = [0, 0]
  until instructions.empty?
    previous = current
    instruction = instructions.shift
    case instruction[:direction]
    when "R"
      current = [previous[0], previous[1] + instruction[:distance]]
    when "D"
      current = [previous[0] + instruction[:distance], previous[1]]
    when "L"
      current = [previous[0], previous[1] - instruction[:distance]]
    when "U"
      current = [previous[0] - instruction[:distance], previous[1]]
    end

    area += (previous[0] * current[1]) - (current[0] * previous[1])
  end

  (area.abs / 2).round(2) + (perimeter / 2) + 1
end

class TestSolution < Test::Unit::TestCase
  def input
    "R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"
  end

  def test_part1
    $debug = true
    assert_equal(62, part1(input))
    $debug = false
  end

  def test_part2
    assert_equal(952408144115, part2(input))
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
