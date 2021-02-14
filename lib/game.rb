require_relative 'board'

class Game
  def initialize
    @board = Board.new
    @turn_counter = 0
  end

  # Public Functions

  def play
    @board.setup_board
  end

  def current_player
    @turn_counter % 2 == 0 ? 'Player 1' : 'Player 2'
  end

  def convert_piece_string(piece_string)
    if piece_string == 'king'
      return '♚'
    elsif piece_string == 'queen'
      return '♛'
    elsif piece_string == 'rook'
      return '♜'
    elsif piece_string == 'bishop'
      return '♝'
    elsif piece_string == 'knight'
      return '♞'
    elsif piece_string == 'pawn'
      return '♟'
    end
  end

  # Get Piece the User would like to move
  def move_piece(player)
    # Gets the Row and Column of the Unit that the Player would like to move
    puts 'Enter the row and column of the unit you would like to move'
    piece_location = gets.chomp

    # Append the Row and Column of the Unit into an Array
    piece_location_array = piece_location.to_s.split('').map(&:to_i)

    # Based off the Row and Column of the Unit, find if the unit e`xists and return the unit
    if player == 'Player 1'
      index = @board.player1.find_index { |unit| unit.location == piece_location_array }
      piece = @board.player1[index]
    else
      index = @board.player2.find_index { |unit| unit.location == piece_location_array }
      piece = @board.player2[index]
    end

    # Get the new Row and Column the Player would like to move the Unit to
    puts 'Enter the location you would like the move the unit to'
    new_piece_location = gets.chomp

    # Append the Row and Column of the Unit into an Array
    new_piece_location_array = new_piece_location.to_s.split('').map(&:to_i)

    # Get an array of possible locations the Unit can be moved to
    possible_positions = piece.possible_positions

    # Check if the new location the Player would like to move the Unit to is a valid location
    if !valid_new_position?(possible_positions, new_piece_location_array)
      return move_piece(player)
    end

    if @board.position_occupied_by_same_team?(piece, new_piece_location_array) == true
      puts 'Position is occupied by another piece from your team'
      return move_piece(player)
    end

    old_piece_location = piece.location

    if @board.position_occupied_by_opponent?(piece, new_piece_location_array) == true
      @board.board[old_piece_location[0]][old_piece_location[1]] = ' '
      @board.board[new_piece_location_array[0]][new_piece_location_array[1]] = piece.type

      if player == 'Player 1'
        @board.player1[index].location = new_piece_location_array
        opponent_index = @board.player2.find_index { |unit| unit.location == new_piece_location_array }
        @board.player2.delete_at(opponent_index)

      else
        @board.player2[index].location = new_piece_location_array
        opponent_index = @board.player1.find_index { |unit| unit.location == new_piece_location_array }
        @board.player1.delete_at(opponent_index)
      end
    end

    # if piece.piece_in_between?(old_piece_location, new_piece_location_array) == true
    #   puts 'Position inbetween the starting position and the new position is occupied by a piece'
    #   return move_piece(player)
    # end

    # If the location is valid, replace the current location of the Unit with the new location
    if @board.board[new_piece_location_array[0]][new_piece_location_array[1]] == ' '
      @board.board[old_piece_location[0]][old_piece_location[1]] = ' '
      if player == 'Player 1'
        @board.player1[index].location = new_piece_location_array
      else
        @board.player2[index].location = new_piece_location_array
      end
      @board.board[new_piece_location_array[0]][new_piece_location_array[1]] = piece.type
    end
    @board.display_board
  end

  # User Input Validation Functions
  def piece_validation?(user_input)
    user_input = user_input.downcase
    return true if %w[king queen rook bishop knight pawn].include?(user_input)
  end

  def integer_validation?(user_input)
    user_input = user_input.to_i
    return true if user_input.between?(0..7)
  end

  def valid_new_position?(possible_positions, new_piece_location)
    possible_positions.each do |position|
      return true if position == new_piece_location
    end
  end

  def rook_can_move?(current_piece, new_piece_location)
    
  end
end

test = Game.new
test.play
# p test.current_player_piece
p test.move_piece('Player 1')
