require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

class Board
  attr_accessor :board, :player1, :player2

  def initialize
    @board = create_board
    @player1 = []
    @player2 = []
  end

  def create_board
    board = []
    8.times do
      board.push(Array.new(8, ' '))
    end
    board
  end

  def display_board
    count = @board[0].length - 1
    until count.negative?
      row = ' '
      @board[count].each do |piece|
        row << (piece)
        row << (' | ')
      end
      count -= 1
      puts row
    end
  end

  def setup_board
    setup_pawns
    setup_rook
    setup_knight
    setup_bishop
    setup_queen
    setup_king
    display_board
  end

  def setup_pawns
    column = 0
    until @board[1].all? && @board[2].all? { |location| location == '♟' }
      white_pawn_location = [1, column]
      white_pawn = Pawn.new(white_pawn_location, column, 'white')
      @board[1][column] = '♟'
      @player1.append(white_pawn)

      black_pawn_location = [2, column]
      black_pawn = Pawn.new(black_pawn_location, column, 'black')
      @board[2][column] = '♟'
      @player2.append(black_pawn)

      column += 1
    end
  end

  def setup_rook
    column = [0, 7]
    count = 0
    until @board[0][0] && @board[0][7] && @board[7][0] && @board[7][7] == '♜'
      white_rook_location = [0, column[count]]
      white_rook = Rook.new(white_rook_location, count, 'white')
      @board[0][column[count]] = '♜'
      @player1.append(white_rook)

      black_rook_location = [7, column[count]]
      black_rook = Rook.new(black_rook_location, count, 'black')
      @board[7][column[count]] = '♜'
      @player2.append(black_rook)

      count += 1
    end
  end

  def setup_knight
    column = [1, 6]
    count = 0
    until @board[0][1] && @board[0][6] && @board[7][1] && @board[7][6] == '♞'
      white_knight_location = [0, column[count]]
      white_knight = Knight.new(white_knight_location, count, 'white')
      @board[0][column[count]] = '♞'
      @player1.append(white_knight)

      black_knight_location = [7, column[count]]
      black_knight = Knight.new(black_knight_location, count, 'black')
      @board[7][column[count]] = '♞'
      @player2.append(black_knight)

      count += 1
    end
  end

  def setup_bishop
    column = [2, 5]
    count = 0
    until @board[0][2] && @board[0][5] && @board[7][2] && @board[7][5] == '♝'
      white_bishop_location = [0, column[count]]
      white_bishop = Bishop.new(white_bishop_location, count, 'white')
      @board[0][column[count]] = '♝'
      @player1.append(white_bishop)

      black_bishop_location = [7, column[count]]
      black_bishop = Bishop.new(black_bishop_location, count, 'black')
      @board[7][column[count]] = '♝'
      @player2.append(black_bishop)

      count += 1
    end
  end

  def setup_queen
    until @board[0][3] && @board[7][3] == '♛'
      white_queen_location = [0, 3]
      white_queen = Queen.new(white_queen_location, 0, 'white')
      @board[0][3] = '♛'
      @player1.append(white_queen)

      black_queen_location = [7, 3]
      black_queen = Queen.new(black_queen_location, 0, 'black')
      @board[7][3] = '♛'
      @player2.append(black_queen)
    end
  end

  def setup_king
    until @board[0][4] && @board[7][4] == '♚'
      white_king_location = [0, 4]
      white_king = King.new(white_king_location, 0, 'white')
      @board[0][4] = '♚'
      @player1.append(white_king)

      black_king_location = [7, 4]
      black_king = King.new(black_king_location, 0, 'black')
      @board[7][4] = '♚'
      @player2.append(black_king)
    end
  end

  def position_occupied_by_same_team?(current_player, new_piece_location)
    if current_player == 'Player 1'
      @player1.each do |piece|
        return true if piece.location == new_piece_location
      end
    else
      @player2.each do |piece|
        return true if piece.location == new_piece_location
      end
    end
  end

  def position_occupied_by_opponent?(current_piece, new_piece_location)
    if current_piece.team == 'white'
      @player2.each do |piece|
        if piece.location == new_piece_location
          return true
        end
      end
    else
      @player1.each do |piece|
        if piece.location == new_piece_location
          return true
        end
      end
    end
  end
end
