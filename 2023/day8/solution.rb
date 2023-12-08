#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  instructions, connections = input.split("\n\n")
  instructions = instructions.chars.map { (_1 == "L") ? 0 : 1 }
  connections = connections.split("\n").each_with_object({}) do |connection, acc|
    key, left, right = /(\w+) = \((\w+), (\w+)\)/.match(connection).captures
    acc[key] = [left, right]
  end
  [instructions, connections]
end

def count_steps_to_finish(connections, instructions, location)
  step_count = 0
  instructions.cycle do |instruction|
    location = connections[location][instruction]
    step_count += 1
    break if yield(location)
  end
  step_count
end

def part1(input)
  instructions, connections = parse(input)
  count_steps_to_finish(connections, instructions, "AAA") { _1 == "ZZZ" }
end

def part2(input)
  instructions, connections = parse(input)
  locations = connections.keys.select { _1 =~ /A$/ }
  periods = locations.map do |start|
    count_steps_to_finish(connections, instructions, start) { _1 =~ /Z$/ }
  end
  periods.reduce(&:lcm)
end

class TestSolution < Test::Unit::TestCase
  def test_part1_1
    assert_equal(2, part1(
      "RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"
    ))
  end

  def test_part1_2
    assert_equal(6, part1(
      "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"
    ))
  end

  def test_part2
    assert_equal(6, part2(
      "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"
    ))
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
