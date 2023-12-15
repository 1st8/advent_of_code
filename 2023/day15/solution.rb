#!/usr/bin/env ruby

require "test/unit"

def p1hash(str)
  str.chars.reduce(0) do |sum, c|
    ((sum + c.ord) * 17) % 256
  end
end

def part1(input)
  input.split(",").sum do |str|
    p1hash(str)
  end
end

def part2(input)
  boxes = 256.times.map { [] }
  input.split(",").each do |label|
    case label.split(/(=|-)/)
    in [label, "=", focal]
      box = boxes[p1hash(label)]
      index = box.index { _1[:label] == label } || box.length
      box[index] = {label:, focal: focal.to_i}
    in [label, "-"]
      box = boxes[p1hash(label)]
      index = box.index { _1[:label] == label }
      box.delete_at(index) if index
    else
      raise "wat #{label}"
    end
  end

  boxes.each_with_index.sum do |box, i|
    (i + 1) * box.each_with_index.sum do |lens, j|
      (j + 1) * lens[:focal]
    end
  end
end

class TestSolution < Test::Unit::TestCase
  def input
    "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
  end

  def test_hash
    assert_equal(52, p1hash("HASH"))
  end

  def test_part1
    assert_equal(1320, part1(input))
  end

  def test_part2
    assert_equal(145, part2(input))
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
