#!/usr/bin/env ruby

require "test/unit"

CARD_VALUES = %w[A K Q J T 9 8 7 6 5 4 3 2].reverse.each_with_index.to_h.freeze
CARD_VALUES2 = %w[A K Q T 9 8 7 6 5 4 3 2 J].reverse.each_with_index.to_h.freeze

def parse(input)
  input.each_line.map do |l|
    cards, bet = l.split(" ")
    cards = cards.chars
    bet = bet.to_i
    {cards:, bet:}
  end
end

def part1(input)
  hands = parse(input)
  hands
    .sort_by { |hand| comparable(score(hand[:cards])) }
    .each_with_index
    .sum { |hand, rank| hand[:bet] * (rank + 1) }
end

def score(cards) =
  case cards.tally.values.sort
  in [5] # five of a kind
    6
  in [1, 4] # four of a kind
    5
  in [2, 3] # full house
    4
  in [1, 1, 3] # three of a kind
    3
  in [1, 2, 2] # two pair
    2
  in [1, 1, 1, 2] # one pair
    1
  else # high card
    0
  end.yield_self do |score|
    [score] + cards.map { CARD_VALUES[_1] }
  end

def comparable(score) =
  score.reverse.each_with_index.sum { |val, i| val * CARD_VALUES.size**i }

def part2(input)
  hands = parse(input)
  hands
    .sort_by { |hand| comparable(score2(hand[:cards])) }
    .each_with_index
    .sum { |hand, rank| hand[:bet] * (rank + 1) }
end

def score2(cards)
  tally = cards.tally
  jokers = tally.delete("J")
  counts = tally.values.sort
  if counts.length > 0
    counts[-1] += jokers.to_i
  else
    counts = [jokers]
  end

  case counts
  in [5] # five of a kind
    6
  in [1, 4] # four of a kind
    5
  in [2, 3] # full house
    4
  in [1, 1, 3] # three of a kind
    3
  in [1, 2, 2] # two pair
    2
  in [1, 1, 1, 2] # one pair
    1
  else # high card
    0
  end.yield_self do |score|
    [score] + cards.map { CARD_VALUES2[_1] }
  end
end

def comparable2(score) =
  score.reverse.each_with_index.sum { |val, i| val * CARD_VALUES2.size**i }

class TestSolution < Test::Unit::TestCase
  def input
    "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"
  end

  def test_score
    assert_equal(6, score("AAAAA".chars).first)
    assert_equal(5, score("AA8AA".chars).first)
    assert_equal(4, score("23332".chars).first)
    assert_equal(3, score("TTT98".chars).first)
    assert_equal(2, score("23432".chars).first)
    assert_equal(1, score("A23A4".chars).first)
    assert_equal(0, score("23456".chars).first)
  end

  def test_comparable
    assert_equal(0, comparable([0]))
    assert_equal(1, comparable([1]))
    assert_equal(13, comparable([1, 0]))
    assert_equal(169, comparable([1, 0, 0]))
    assert_equal(170, comparable([1, 0, 1]))
  end

  def test_part1
    assert_equal(6440, part1(input))
  end

  def test_score2
    assert_equal(1, score2("32T3K".chars).first)
    assert_equal(2, score2("KK677".chars).first)
    assert_equal(5, score2("T55J5".chars).first)
    assert_equal([5, 11, 9, 0, 0, 9], score2("KTJJT".chars))
    assert_equal(5, score2("QQQJA".chars).first)
  end

  def test_ranking
    ranked = %w[32T3K T55J5 KK677 KTJJT QQQJA].sort_by { comparable(score2(_1.chars)) }
    assert_equal(%w[32T3K KK677 T55J5 QQQJA KTJJT], ranked)
    ranked = %w[AAAAA JJJJJ].sort_by { comparable(score2(_1.chars)) }
    assert_equal(%w[JJJJJ AAAAA], ranked)
  end

  def test_part2
    assert_equal(5905, part2(input))
  end
end

def measure(label)
  require "benchmark"
  res = nil
  real = Benchmark.measure { res = yield }.real
  puts "%s: %s (took: %.4fms)" % [label, res.inspect, real * 1000]
end

if Test::Unit::AutoRunner.run
  input = File.read("input.txt").strip.freeze
  measure("Part1") { part1(input) }
  measure("Part2") { part2(input) }
end
