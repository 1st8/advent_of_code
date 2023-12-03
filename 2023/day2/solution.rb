#!/usr/bin/env ruby

require "test/unit"

def parse(input)
  input.each_line.map do |l|
    matches = l.match(/^Game (\d+): (.+)$/)
    id = matches[1].to_i
    samples = matches[2].split("; ").map do |raw_sample|
      raw_sample.split(", ").map {
        count, color = _1.split(" ")
        [color.to_sym, count.to_i]
      }.to_h
    end
    maximums = samples.each_with_object({}) do |sample, max|
      sample.each do |color, count|
        max[color] = [max[color] || 0, count].max
      end
    end
    {id:, samples:, maximums:}
  end
end

def part1(input)
  limits = {red: 12, green: 13, blue: 14}
  games = parse(input)

  possible_games = games.select do |game|
    game[:maximums].all? { |color, count| limits[color] >= count }
  end
  possible_games.sum { _1[:id] }
end

def part2(input)
  games = parse(input)
  games.map { _1[:maximums].values.reduce(&:*) }.sum
end

class TestSolution < Test::Unit::TestCase
  def test_part1
    input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
    assert_equal(8, part1(input))
  end
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip
  puts "Part1: #{part1(input)}"
  puts "Part2: #{part2(input)}"
end
