#!/usr/bin/env ruby

require "test/unit"

class Node
  attr_accessor :coords, :vec, :cost, :parent

  def initialize(coords, vec, cost = Float::INFINITY, parent = nil)
    @coords, @vec, @cost, @parent = coords, vec, cost, parent
  end

  def ==(other)
    coords == other.coords && vec == other.vec
  end

  def hash
    [coords, vec].hash
  end

  def eql?(other)
    self == other
  end

  def inspect
    "Node[#{coords}, #{vec}]"
  end
end

def dijkstra(start, goal, grid, range)
  startx = Node.new(start, [0, 1], 0)
  starty = Node.new(start, [1, 0], 0)
  goalx = Node.new(goal, [0, 1], 0)
  goaly = Node.new(goal, [1, 0], 0)
  open_set = [startx, starty]
  closed_set = Set.new

  until open_set.empty? && goal_set.empty?
    current_node = open_set.min_by { |node| node.cost }

    return current_node if current_node == goalx || current_node == goaly

    open_set.delete(current_node)
    closed_set.add(current_node)

    y, x = current_node.coords
    cost = 0
    neighbors =
      if current_node.vec[0] == 0 # horizontal
        range.flat_map do |i|
          next_coords = [y, x + i * current_node.vec[1]]
          node_cost = grid.dig(*next_coords)
          next [] if node_cost.nil?
          cost += node_cost
          [
            Node.new(next_coords, [-1, 0], current_node.cost + cost, current_node),
            Node.new(next_coords, [1, 0], current_node.cost + cost, current_node)
          ]
        end
      else # vertical
        range.flat_map do |i|
          next_coords = [y + i * current_node.vec[0], x]
          node_cost = grid.dig(*next_coords)
          next [] if node_cost.nil?
          cost += node_cost
          [
            Node.new(next_coords, [0, -1], current_node.cost + cost, current_node),
            Node.new(next_coords, [0, 1], current_node.cost + cost, current_node)
          ]
        end
      end

    neighbors.reject! { |n| n.coords.any?(&:negative?) || closed_set.include?(n) }
    open_set += neighbors
  end

  nil
end

def reconstruct_path(node)
  path = []
  while node
    path << node.coords
    node = node.parent
  end
  path.reverse
end

def parse(input)
  input.split("\n").map { _1.chars.map(&:to_i) }
end

def part1(input)
  data = parse(input)
  node = dijkstra([0, 0], [data.length - 1, data.first.length - 1], data, 1..3)
  path = reconstruct_path(node)

  if $debug
    data.each_with_index do |l, y|
      l.each_with_index do |c, x|
        if path.include?([y, x])
          print "\e[31m#{c}\e[0m"
        else
          print c
        end
      end
      puts
    end
    puts "\n\n"
  end

  node.cost
end

def part2(input)
end

class TestSolution < Test::Unit::TestCase
  def input
    "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"
  end

  def test_part1
    $debug = true
    assert_equal(102, part1(input))
    $debug = false
  end

  def test_part2
    # assert_equal(94, part2(input))
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
