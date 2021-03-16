require 'colorize'

require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

class NewBoard
	attr_accessor :board, :white_player, :black_player

  def initialize
    @board = create_board
    @white_player = []
    @black_player = []
  end

	def setup_board
		setup_pawns()
		setup_rooks()
		setup_knights()
		setup_bishops()
		setup_queens()
		setup_kings()
	end

  def create_board
    board = []
    8.times do
      board.push(Array.new(8, ' '))
    end
    board
  end

  def display_board_player_white(board)
    count = board[0].length - 1
    until count.negative?
      row = ''
			row << ("#{count + 1}  ")
      board[count].each_with_index do |piece, index|
        if index.even? && count.odd?
          row << (" #{piece}  ".on_green + '|')
        end
        if index.even? && count.even?
          row << (" #{piece}  ".on_light_black + '|')
        end
        if index.odd? && count.odd?
          row << (" #{piece}  ".on_light_black + '|')
        end
        if index.odd? && count.even?
          row << (" #{piece}  ".on_green + '|')
        end
      end
      count -= 1
      puts row
    end
		puts '    a    b    c    d    e    f    g    h   '
  end

	def display_board_player_black(board)
		count = board[0].length
		row_display = count.clone
		counter = 0
		until counter == count
			row = ''
			row << ("#{row_display} ")
			board[counter].each_with_index do |piece, index|
				if index.even? && counter.odd?
					row << (" #{piece}  ".on_green + '|')
				end
				if index.even? && counter.even?
					row << (" #{piece}  ".on_light_black + '|')
				end
				if index.odd? && counter.odd?
					row << (" #{piece}  ".on_light_black + '|')
				end
				if index.odd? && counter.even?
					row << (" #{piece}  ".on_green + '|')
				end
			end
			row_display -= 1
			counter += 1
			puts row
		end
		puts '    a    b    c    d    e    f    g    h   '
	end

  # ------------------------------ Functions to Setup Pieces on Board ------------------------------ #

  def setup_pawns
    column = 0
    until column == 8
      white_pawn_location = [1, column]
      white_pawn = Pawn.new(white_pawn_location, 'White')
      @board[1][column] = '♟'.white
      @white_player.append(white_pawn)
        
      black_pawn_location = [6, column]
      black_pawn = Pawn.new(black_pawn_location, 'Black')
      @board[6][column] = '♟'.black
      @black_player.append(black_pawn)

      column += 1
    end
  end

  def setup_rooks
    column = [0, 7]
    count = 0
    until count == 2
      white_rook_location = [0, column[count]]
      white_rook = Rook.new(white_rook_location, 'White')
      @board[0][column[count]] = '♜'.white
      @white_player.append(white_rook)

      black_rook_location = [7, column[count]]
      black_rook = Rook.new(black_rook_location, 'Black')
      @board[7][column[count]] = '♜'.black
      @black_player.append(black_rook)

      count += 1
    end
  end

  def setup_knights
		column = [1, 6]
		count = 0
		until count == 2
			white_knight_location = [0, column[count]]
			white_knight = Knight.new(white_knight_location, 'White')
			@board[0][column[count]] = '♞'.white
			@white_player.append(white_knight)

			black_knight_location = [7, column[count]]
			black_knight = Knight.new(black_knight_location, 'Black')
			@board[7][column[count]] = '♞'.black
			@black_player.append(black_knight)

			count += 1
		end
  end

	def setup_bishops
		column = [2, 5]
		count = 0
		until count == 2
			white_bishop_location = [0, column[count]]
			white_bishop = Bishop.new(white_bishop_location, 'White')
			@board[0][column[count]] = '♝'.white
			@white_player.append(white_bishop)

			black_bishop_location = [7, column[count]]
			black_bishop = Bishop.new(black_bishop_location, 'Black')
			@board[7][column[count]] = '♝'.black
			@black_player.append(black_bishop)

			count += 1
		end
	end

	def setup_queens
		white_queen_location = [2, 4]
		white_queen = Queen.new(white_queen_location, 'White')
		@board[2][4] = '♛'.white
		@white_player.append(white_queen)

		black_queen_location = [7, 3]
		black_queen = Queen.new(black_queen_location, 'Black')
		@board[7][3] = '♛'.black
		@black_player.append(black_queen)
	end

	def setup_kings
		white_king_location = [0, 4]
		white_king = King.new(white_king_location, 'White')
		@board[0][4] = '♚'.white
		@white_player.append(white_king)

		black_king_location = [5, 4]
		black_king = King.new(black_king_location, 'Black')
		@board[5][4] = '♚'.black
		@black_player.append(black_king)
	end
end
