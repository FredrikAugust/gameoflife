#!/usr/bin/env ruby
#
# Copyright (c) 2016 Fredrik A. Madsen-Malmo <mail.fredrikaugust@gmail.com>
#
# Distributed under terms of the GPLv3 license.

require 'ncurses'

Ncurses.initscr
Ncurses.curs_set(0)

SIZE = File.open('board.txt').count

# main class that contains all logic
class GameOfLife
  def initialize
    @board = Array.new(SIZE) { Array.new(SIZE, 0) }

    content = File.readlines 'board.txt'
    content.each_with_index do |line, y|
      line.chomp.split('').each_with_index { |c, x| @board[x][y] = c.to_i }
    end
  end

  def show
    @board.transpose.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        Ncurses.mvaddstr(x, y, (cell == 1 ? 'O' : '.'))
        Ncurses.refresh
      end
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

  # return the sum of alive neighbors
  def neighbours(pos_x, pos_y)
    cells = neighbours_coords(pos_x, pos_y).flatten.each_slice(2).map do |c|
      next if c.any? { |coord| coord < 0 || coord > SIZE - 1 }
      cell(c[0], c[1])
    end

    cells.delete_if(&:nil?)

    cells.nil? ? 0 : cells.inject(0, :+)
  end

  # get value of cell
  def cell(pos_x, pos_y)
    @board[pos_x][pos_y]
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
    temp_board = Array.new(SIZE) { Array.new(SIZE, 0) }

    (0...SIZE).each do |x|
      (0...SIZE).each do |y|
        temp_board[x][y] = live_or_die(x, y)
      end
    end

    @board = temp_board
  end

  # close down everything and enable cursor
  def close_game
    show
    Ncurses.mvaddstr(Ncurses.getmaxy(Ncurses.stdscr) - 1, 0,
                     'Press any key to exit')
    Ncurses.getch
    Ncurses.curs_set(1)
    Ncurses.endwin
  end

  # run the program x times
  def run(times = 2500, sleep_period = 0)
    times.times do
      show
      evolve
      sleep(sleep_period)
    end
  ensure
    close_game
  end
end

game = GameOfLife.new
game.show # before the program starts
game.run
