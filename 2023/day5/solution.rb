#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  seeds, *maps = input.split(/\n\n.*?map:\n/)
  _, *seeds = seeds.split(" ")
  [
    seeds.map(&:to_i),
    maps.map do |l|
      l.split("\n").map do
        dest, src, length = _1.split(" ").map(&:to_i)
        {src: src..(src + length - 1), dest: dest..(dest + length - 1)}
      end
    end
  ]
end

def part1(input)
  seeds, stages = parse(input)

  locations = seeds.map do |seed|
    stages.reduce(seed) do |val, maps|
      map = maps.find { |map| map[:src].include?(val) }
      if map
        val - map[:src].begin + map[:dest].begin
      else
        val
      end
    end
  end
  locations.min
end

def part2(input)
  seed_ranges, stages = parse(input)
  seed_ranges = seed_ranges.each_slice(2).map do |start, length|
    start..(start + length - 1)
  end

  location_ranges = stages.reduce(seed_ranges) do |ranges, stage|
    unmapped = ranges
    output = []

    stage.each do |map|
      new_unmapped = []
      unmapped.each do |range|
        result = map_range(range, map)
        output << result[:mapped] if result[:mapped]
        new_unmapped += result[:unmapped]
      end
      unmapped = new_unmapped
    end

    output + unmapped
  end

  location_ranges.map { _1.begin }.min
end

def map_range(range, map)
  if range == map[:src]
    {mapped: map[:dest], unmapped: []}
  elsif map[:src].begin > range.end || range.begin > map[:src].end
    {mapped: nil, unmapped: [range]}
  # range in src
  elsif map[:src].include?(range.begin) && map[:src].include?(range.end)
    start = (range.begin - map[:src].begin + map[:dest].begin)
    {mapped: start..(start + range.size - 1), unmapped: []}
  # src in range
  elsif range.include?(map[:src].begin) && range.include?(map[:src].end)
    {
      mapped: map[:dest],
      unmapped: [
        (range.begin)..(map[:src].begin - 1),
        (map[:src].end + 1)..range.end
      ]
    }
  # begin overlap
  elsif range.begin < map[:src].begin && range.end <= map[:src].end
    overlap_size = range.end - map[:src].begin
    {
      unmapped: [range.begin..(map[:src].begin - 1)],
      mapped: (map[:dest].begin)..(map[:dest].begin + overlap_size)
    }
  # end overlap
  elsif range.begin <= map[:src].end && range.end > map[:src].end
    overlap_size = map[:src].end - range.begin

    {
      mapped: (map[:dest].end - overlap_size)..(map[:dest].end),
      unmapped: [(map[:src].end + 1)..(range.end)]
    }
  else
    {unmapped: [range], mapped: nil}
  end
end

def compress(ranges)
  ranges
    .sort_by!(&:begin)
  result = []
  start = ranges.first.begin
  ranges.each_cons(2) do |r1, r2|
    if r1.end < r2.begin - 1
      result << (start..(r1.end))
      start = r2.begin
    end
  end
  result << (start..(ranges.last.end))
  result
end

def part2_brute_ractors(input)
  seed_ranges, stages = parse(input)
  seed_ranges = seed_ranges.each_slice(2).map do |start, length|
    start..(start + length - 1)
  end

  max_range_size = 250_000
  seed_ranges = seed_ranges.sort_by(&:size).flat_map do |range|
    ranges = []
    while range.size > max_range_size
      ranges << ((range.begin)..(range.begin + max_range_size))
      range = (range.begin + max_range_size + 1)..(range.end)
    end
    ranges << range
  end

  require "etc"
  ractors = Etc.nprocessors.times.map do
    Ractor.new do
      stages_in_ractor = receive
      loop do
        range_in_ractor = receive
        break if range_in_ractor.nil?

        result = range_in_ractor.map do |seed|
          stages_in_ractor.reduce(seed) do |val, maps|
            map = maps.find { |map| map[:src].include?(val) }
            if map
              val - map[:src].begin + map[:dest].begin
            else
              val
            end
          end
        end
        Ractor.yield result
      end
    end
  end

  ractors.each { _1.send(stages) }
  puts "Ractors started: #{ractors.count}"

  results = []
  while seed_ranges.size > 0
    working = ractors.filter_map do |r|
      range = seed_ranges.shift
      next nil if range.nil?
      r.send(range)
      r
    end

    while working.size > 0
      r, obj = Ractor.select(*ractors)
      working -= [r]
      results << obj.min
    end
    puts [seed_ranges.size / 8].inspect
  end
  ractors.each { _1.send(nil) }
  results.min
end

class TestSolution < Test::Unit::TestCase
  def input
    "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"
  end

  def test_part1
    assert_equal(35, part1(input))
  end

  def test_range_mapping_begin_overlap
    assert_equal(
      {
        unmapped: [1..2],
        mapped: 13..15
      },
      map_range(1..5, {src: 3..6, dest: 13..16})
    )
  end

  def test_range_mapping_end_overlap
    assert_equal(
      {
        mapped: 14..16,
        unmapped: [7..8]
      },
      map_range(4..8, {src: 1..6, dest: 13..16})
    )
  end

  def test_range_mapping_included
    assert_equal(
      {
        mapped: 13..14,
        unmapped: []
      },
      map_range(3..4, {src: 1..5, dest: 11..15})
    )
  end

  def test_range_mapping_complete_overlap
    assert_equal(
      {mapped: 0..1, unmapped: [35..68, 71..76]},
      map_range(
        35..76,
        {src: 69..70, dest: 0..1}
      )
    )
  end

  def test_range_mapping_begin_overlap2
    assert_equal(
      {
        mapped: 90..97,
        unmapped: [94..99]
      },
      map_range(
        86..99,
        {src: 56..93, dest: 60..97}
      )
    )
  end

  def test_range_mapping_no_overlap
    assert_equal(
      {unmapped: [47..65], mapped: nil},
      map_range(
        47..65,
        {src: 69..70, dest: 0..1}
      )
    )
  end

  def test_compress
    assert_equal(
      [1..4],
      compress([
        1..2,
        3..4
      ])
    )
    assert_equal(
      [1..2, 4..5],
      compress([
        1..2,
        4..5
      ])
    )
    assert_equal(
      [1..7],
      compress([
        1..3,
        1..5,
        4..7
      ])
    )
    assert_equal(
      [55..70, 79..95],
      compress([79..93, 81..95, 55..68, 57..70])
    )
  end

  def test_part2
    assert_equal(46, part2(input))
  end

  def test_part2_brute_ractors
    assert_equal(46, part2_brute_ractors(input))
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
