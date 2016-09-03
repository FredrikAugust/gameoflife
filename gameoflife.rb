#!/usr/bin/env ruby
#
# Copyright (c) 2016 Fredrik A. Madsen-Malmo <mail.fredrikaugust@gmail.com>
#
# Distributed under terms of the GPLv3 license.

SIZE = 20

# main class that contains all logic
class GameOfLife
  def initialize
    @board = Array.new(SIZE) { Array.new(SIZE, 0) }
    @board[0][0] = 1
    @board[1][0] = 1
    @board[1][1] = 1
    @board[0][1] = 1
    @board[2][0] = 1
    @board[2][2] = 1
    @board[0][2] = 1
    @board[2][SIZE-1] = 1
  end

  def show
    @board.transpose.each do |row|
      row.each { |cell| print cell }
      print "\n"
    end
  end

  def neighbours_coords(pos_x, pos_y)
    coord = [pos_x, pos_y]

    # loop through coords
    [0, 1].map do |pos|
      # loop through add/subtract 1
      [1, -1].map do |diff|
        # if x-axis; add/sub 1 to x-axis and use y as normal and etc.
        pos.zero? ? [coord[0] + diff, coord[1]] : [coord[0], coord[1] + diff]
      end
    end.flatten.each_slice(2) # get coords in arrs of two
  end

  # return the sum of alive neighbors
  def neighbours(pos_x, pos_y)
    neighbours_coords(pos_x, pos_y).map do |coord|
      if coord.any? { |c| c < 0 || c > SIZE }
        0
      else
        @board[coord[0]][coord[1]]
      end
    end.inject(:+) # sum
  end

  # determine whether the cell should live or die
  def live_or_die(pos_x, pos_y)
  end
end

game = GameOfLife.new
game.show
puts game.neighbours(2, 0).inspect
