#!/usr/bin/env ruby
#
# Copyright (c) 2016 Fredrik A. Madsen-Malmo <mail.fredrikaugust@gmail.com>
#
# Distributed under terms of the GPLv3 license.

require 'gosu'

MAXX = 200
MAXY = 100

# main class that contains all logic
class GameOfLife
  def initialize
    @board = Array.new(MAXX) { Array.new(MAXY, 0) }
    content = File.readlines 'board.txt'
    content.each_with_index do |line, y|
      line.chomp.split('').each_with_index { |c, x| @board[y][x] = c.to_i }
    end

    fill_board
  end

  # fill up the part of the board that isn't specified in input file
  def fill_board
    MAXY.times do |t|
      @board << Array.new(MAXX, 0) if @board[t].nil?
    end

    @board.map! do |row|
      row << [0] * (MAXX - row.size)
      row.flatten
    end
  end

  def neighbours_coords(pos_x, pos_y)
    coords = []

    [
      [-1, -1], [0, -1], [1, -1],
      [-1, 0],           [1, 0],
      [-1, 1],  [0, 1],  [1, 1]
    ].each do |pos|
      coords << [pos_x + pos[0], pos_y + pos[1]]
    end

    coords
  end

  # check if cell goes outside boundary
  def invalid_cell?(pos)
    pos[0] < 0 || pos[1] < 0 || pos[0] > MAXX || pos[1] > MAXY
  end

  # return the sum of alive neighbors
  def neighbours(pos_x, pos_y)
    cells = neighbours_coords(pos_x, pos_y).flatten.each_slice(2).map do |c|
      next if invalid_cell? c
      cell(c[0], c[1])
    end

    cells.delete_if(&:nil?)

    cells.nil? ? 0 : cells.inject(0, :+)
  end

  # get value of cell
  def cell(pos_x, pos_y)
    @board[pos_y][pos_x]
  end

  # determine whether the cell should live or die
  def live_or_die(pos_x, pos_y)
    cell_neighbours = neighbours(pos_x, pos_y)

    case cell_neighbours
    when 0, 1 then return 0
    when 2
      return 1 if cell(pos_x, pos_y) == 1
    when 3 then return 1
    when cell_neighbours > 3 then return 0
    end

    0
  end

  # evolve the board
  def evolve
    # store the new board in here
    temp_board = Array.new(MAXX) { Array.new(MAXY, 0) }

    (0...MAXX).each do |x|
      (0...MAXY).each do |y|
        temp_board[y][x] = live_or_die(x, y)
      end
    end

    @board = temp_board
  end

  attr_reader :board
end

# gosu main class for displaying game
class GameOfLifeWindow < Gosu::Window
  def initialize
    super MAXX, MAXY, :fullscreen
    self.caption = 'Game of Life'

    @game = GameOfLife.new
  end

  def update
    exit if Gosu.button_down? Gosu.char_to_button_id('q')
    @game.evolve
  end

  def draw
    @game.board.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        color = cell == 1 ? 0xffffffff : 0xff000000

        draw_quad(y, x, color, y + 1, x, color, y, x + 1, color,
                  y + 1, x + 1, color, 100)
      end
    end
  end
end

window = GameOfLifeWindow.new
window.show
