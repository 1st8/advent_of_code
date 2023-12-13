#!/usr/bin/env ruby

require "test/unit"

def parse(input)
end

def part1(input)
  input.split("\n\n").sum do |pattern|
    v_mirr = find_mirror(pattern)
    h_mirr = find_mirror(pattern.lines.map(&:strip).map(&:chars).transpose.map(&:join).join("\n"))

    v_mirr.to_i * 100 + h_mirr.to_i
  end
end

def find_mirror(pattern, smudges: 0)
  lines = pattern.lines.map(&:strip)
  i = 0
  while i < lines.length - 1
    a = lines[0..i]
    b = lines[(i + 1)..(lines.length)]
    size = [a.length, b.length].min
    a = a.last(size) if a.length > size
    b = b.first(size) if b.length > size

    return i + 1 if a.flat_map(&:chars).zip(b.reverse.flat_map(&:chars)).count { _1 != _2 } == smudges

    i += 1
  end

  nil
end

def part2(input)
  input.split("\n\n").sum do |pattern|
    v_mirr = find_mirror(pattern, smudges: 1)
    h_mirr = find_mirror(pattern.lines.map(&:strip).map(&:chars).transpose.map(&:join).join("\n"), smudges: 1)

    v_mirr.to_i * 100 + h_mirr.to_i
  end
end

class TestSolution < Test::Unit::TestCase
  def input
    "#.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#"
  end

  def test_part1
    assert_equal(405, part1(input))
  end

  def test_part2
    assert_equal(400, part2(input))
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
