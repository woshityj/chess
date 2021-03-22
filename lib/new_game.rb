require 'colorize'

require_relative 'new_board'

class NewGame

  BOARD_COLUMN_ALPHABET_TO_INTEGER = 
  {
    'a' => 1,
    'b' => 2,
    'c' => 3,
    'd' => 4,
    'e' => 5,
    'f' => 6,
    'g' => 7,
    'h' => 8
        
  }

  BLACK_PLAYER_INPUT_ROW_CONVERT = 
  {
    1 => 8,
    2 => 7,
    3 => 6,
    4 => 5,
    5 => 4,
    6 => 3,
    7 => 2,
    8 => 1
  }

  def initialize
    @board = NewBoard.new
    @turn_count = 0
    @white_player_score = 0
    @black_player_score = 0
    @white_player_captured = []
    @black_player_captured = []
    @king_checkmated = false
  end

  def start_menu
    puts "\e[2J"
    puts 'Welcome to Chess in Command Line Interface built with Ruby'.colorize(:green)
    puts "\n"
    puts 'Each turn will be played in 2 different steps'
    puts "\n"
    puts 'Step 1:'
    puts 'Enter the coordinates of the piece you want to move'
    puts 'Step 2:'
    puts 'Enter the coordinates of any legal move or capture'
    puts "\n"
    puts 'To begin, enter one of the following to play:'
    puts "\n"
    puts '[1] to play a new 1-player game against the computer'
    puts '[2] to play a new 2-player game'
    puts '[3] to play a saved game'

    user_input = gets.chomp
  end

  def two_player_game
    @board.setup_board
    until @king_checkmated ==  true
      puts "\e[2]"
      player_turn()
      @turn_count += 1
    end
  end

  # ------------------------------ Private Functions ------------------------------ #


  # ------------------------------ 2 Player Game Functions ------------------------------ #

  def player_turn

    display_player_board()

    coordinates = get_coordinates()

    selected_piece = get_selected_piece(coordinates)

    p selected_piece.team
    
    display_legal_moves(selected_piece)

    new_coordinates = get_coordinates()

    if valid_new_coordinates?(selected_piece, new_coordinates) != true
      puts 'Invalid Coordinates Entered. Please Try Again.'
      return player_turn
    end
    if new_coordinates_occupied_by_opponent?(new_coordinates) == true
      capture_opponent_piece(selected_piece, new_coordinates)
    end
    
    move_piece(selected_piece, new_coordinates)

    if king_is_checked?() == true
      puts 'King is Checked'
      if king_is_checkmated?() == true
        puts "#{current_player()} Player has Checkmated the Opponent's King"
        puts "Congratulations"
        @king_checkmated = true
      end
    end

    display_player_board()

    display_captured_pieces()

  end

  def get_coordinates
    coordinates = gets.chomp

    coordinates_array = coordinates.to_s.split('')

    coordinates_column_integer = BOARD_COLUMN_ALPHABET_TO_INTEGER[coordinates_array[0]]

    if current_player() == 'Black'
      coordinates_row_integer = coordinates_array[1].to_i
      coordinates_row_converted_integer = BLACK_PLAYER_INPUT_ROW_CONVERT[coordinates_row_integer]
      coordinates_array.pop()
      coordinates_array.append(coordinates_row_converted_integer)
    end

    coordinates_array.shift

    coordinates_array.append(coordinates_column_integer)

    coordinates_array = coordinates_array.map(&:to_i)

    coordinates_array[0] -= 1
    coordinates_array[1] -= 1
    coordinates_array
  end

  def display_legal_moves(selected_piece)
    temporary_board = @board.board.dup.map(&:dup)

    legal_moves = selected_piece.possible_positions

    if selected_piece.type == '♟' && opponent_piece_diagonally_of_pawn(selected_piece).empty? != true
      diagonal_opponent_pieces_coordinates = opponent_piece_diagonally_of_pawn(selected_piece)
      diagonal_opponent_pieces_coordinates.each do |capturable_opponent_coordinates|
        legal_moves.append(capturable_opponent_coordinates)
      end
    end

    legal_moves.each do |legal_coordinates|
      if selected_piece.type == '♟'
        occupied_coordinates = piece_infront_pawn(selected_piece)
        next if occupied_coordinates.include?(legal_coordinates) == true
      end

      if selected_piece.type == '♜'
        occupied_coordinates = piece_between_rook(selected_piece)
        next if occupied_coordinates.include?(legal_coordinates) == true
      end

      if selected_piece.type == '♝'
        occupied_coordinates = piece_between_bishop(selected_piece)
        next if occupied_coordinates.include?(legal_coordinates) == true
      end

      if selected_piece.type == '♛'
        occupied_coordinates = piece_between_queen(selected_piece)
        next if occupied_coordinates.include?(legal_coordinates) == true
      end

      if selected_piece.type == '♚'
        occupied_coordinates = piece_infront_king(selected_piece)
        next if occupied_coordinates.include?(legal_coordinates) == true
      end

      if temporary_board[legal_coordinates[0]][legal_coordinates[1]] != ' '
        piece_on_legal_coordinates = temporary_board[legal_coordinates[0]][legal_coordinates[1]]
        temporary_board[legal_coordinates[0]][legal_coordinates[1]] = "#{piece_on_legal_coordinates}".red
      else
        temporary_board[legal_coordinates[0]][legal_coordinates[1]] = '●'.red
      end
    end

    return @board.display_board_player_white(temporary_board) if current_player() == 'White'
    return @board.display_board_player_black(temporary_board) if current_player() == 'Black'
  end

  def valid_new_coordinates?(selected_piece, new_coordinates)
    legal_moves = selected_piece.possible_positions

    if selected_piece.type == '♟' && opponent_piece_diagonally_of_pawn(selected_piece).empty? != true
      diagonal_opponent_pieces_coordinates = opponent_piece_diagonally_of_pawn(selected_piece)
      diagonal_opponent_pieces_coordinates.each do |capturable_opponent_coordinates|
        legal_moves.append(capturable_opponent_coordinates)
      end
      if piece_infront_pawn(selected_piece).empty? != true
        occupied_coordinates = piece_infront_pawn(selected_piece)
        legal_moves = legal_moves - occupied_coordinates
      end
    end

    if selected_piece.type == '♜'
      if piece_between_rook(selected_piece).empty? != true
        occupied_coordinates = piece_between_rook(selected_piece)
        legal_moves = legal_moves - occupied_coordinates
      end
    end

    if selected_piece.type == '♝'
      if piece_between_bishop(selected_piece).empty? != true
        occupied_coordinates = piece_between_bishop(selected_piece)
        legal_moves = legal_moves - occupied_coordinates
      end
    end

    if selected_piece.type == '♛'
      if piece_between_queen(selected_piece).empty? != true
        occupied_coordinates = piece_between_queen(selected_piece)
        occupied_coordinates.each do |occupied_coordinate|
          legal_moves = legal_moves - occupied_coordinate
        end
      end
    end

    if selected_piece.type == '♚'
      if piece_infront_king(selected_piece).empty? != true
        occupied_coordinates = piece_infront_king(selected_piece)
        occupied_coordinates.each do |occupied_coordinate|
          legal_moves = legal_moves - occupied_coordinate
        end
      end
    end

    legal_moves.each do |legal_coordinates|
      return true if legal_coordinates == new_coordinates
    end
  end

  def new_coordinates_occupied_by_opponent?(new_coordinates)
    if current_player() == 'White'
      if @board.board[new_coordinates[0]][new_coordinates[1]] != ' '
        @board.black_player.find_index do |piece|
          return true if piece.location == new_coordinates
        end
      end
    end
    if current_player() == 'Black'
      if @board.board[new_coordinates[0]][new_coordinates[1]] != ' '
        @board.white_player.find_index do |piece|
          return true if piece.location == new_coordinates
        end
      end
    end
  end

  def get_selected_piece(coordinates)
    if current_player() == 'White'
      index = @board.white_player.find_index { |unit| unit.location == coordinates }
      return @board.white_player[index] if index != nil
    end
    if current_player() == 'Black'
      index = @board.black_player.find_index { |unit| unit.location == coordinates }
      return @board.black_player[index] if index != nil
    end
  end

  def current_player
    @turn_count % 2 == 0 ? 'White' : 'Black'  
  end

  def display_player_board
    player = current_player()
    return @board.display_board_player_white(@board.board) if player == 'White'
    return @board.display_board_player_black(@board.board) if player == 'Black'
  end

  def display_captured_pieces
    if current_player() == 'White'
      puts 'White Player Score:'
      puts "#{@white_player_score}"
      puts "#{@white_player_captured}"
    end
    
    if current_player() == 'Black'
      puts 'Black Player Score:'
      puts "#{@black_player_score}"
      puts "#{@black_player_captured}"
    end
  end

  def move_piece(selected_piece, new_coordinates)
    current_coordinates = selected_piece.location
    @board.board[current_coordinates[0]][current_coordinates[1]] = ' '

    if current_player() == 'White'
      index = @board.white_player.find_index { |unit| unit.location == current_coordinates }
      @board.white_player[index].location = new_coordinates
      @board.board[new_coordinates[0]][new_coordinates[1]] = selected_piece.type.white
    end
    if current_player() == 'Black'
      index = @board.black_player.find_index { |unit| unit.location == current_coordinates }
      @board.black_player[index].location = new_coordinates
      @board.board[new_coordinates[0]][new_coordinates[1]] = selected_piece.type.black
    end
  end

  def capture_opponent_piece(selected_piece, new_coordinates)
    if current_player() == 'White'
      index = @board.black_player.find_index { |unit| unit.location == new_coordinates }
      captured_piece = @board.black_player[index]
      @white_player_score = @white_player_score + captured_piece.points
      @white_player_captured.append(captured_piece.type)
      @board.black_player.delete_at(index)
    end

    if current_player() == 'Black'
      index = @board.white_player.find_index { |unit| unit.location == new_coordinates }
      captured_piece = @board.white_player[index]
      @black_player_score = @black_player_score + captured_piece.points
      @black_player_captured.append(captured_piece.type)
      @board.white_player.delete_at(index)
    end
  end

  def piece_infront_pawn(selected_piece)
    occupied_coordinates = []
    copy_of_current_coordinates = selected_piece.location.clone

    if current_player() == 'White'
      if selected_piece.moved == false
        one_step_forward_coordinates = copy_of_current_coordinates[0] + 1
        two_step_forward_coordinates = copy_of_current_coordinates[0] + 2
        if @board.board[one_step_forward_coordinates][copy_of_current_coordinates[1]] != ' '
          occupied_coordinates.append([one_step_forward_coordinates, copy_of_current_coordinates[1]])
          occupied_coordinates.append([two_step_forward_coordinates, copy_of_current_coordinates[1]])
        end
        if @board.board[two_step_forward_coordinates][copy_of_current_coordinates[1]] != ' '
          occupied_coordinates.append([two_step_forward_coordinates, copy_of_current_coordinates[1]])
        end
      end
    end

    if current_player() == 'Black'
      if selected_piece.moved == false
        one_step_forward_coordinates = copy_of_current_coordinates[0] - 1
        two_step_forward_coordinates = copy_of_current_coordinates[0] - 2
        if @board.board[one_step_forward_coordinates][copy_of_current_coordinates[1]] != ' '
          occupied_coordinates.append([one_step_forward_coordinates, copy_of_current_coordinates[1]])
          occupied_coordinates.append([two_step_forward_coordinates, copy_of_current_coordinates[1]])
        end
        if @board.board[two_step_forward_coordinates][copy_of_current_coordinates[1]] != ' '
          occupied_coordinates.append([two_step_forward_coordinates, copy_of_current_coordinates[1]])
        end
      end
    end

    return occupied_coordinates
  end

  def new_coordinates_occupied_by_same_team?(selected_piece, new_coordinates)
    if selected_piece.team == 'White'
      if @board.board[new_coordinates[0]][new_coordinates[1]] != ' '
        @board.white_player.find_index do |piece|
          return true if piece.location == new_coordinates
        end
      end
    elsif selected_piece.team == 'Black'
      if @board.board[new_coordinates[0]][new_coordinates[1]] != ' '
        @board.black_player.find_index do |piece|
          return true if piece.location == new_coordinates
        end
      end
    end
  end

  def opponent_piece_diagonally_of_pawn(selected_piece)
    copy_of_current_coordinates = selected_piece.location.clone

    capturable_opponent_coordinates = []

    if selected_piece.team == 'White'
      top_left_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] + 1, copy_of_current_coordinates[1] - 1]
      top_right_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] + 1, copy_of_current_coordinates[1] + 1]
      if @board.board[top_left_diagonally_of_current_coordinates[0]][top_right_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, top_left_diagonally_of_current_coordinates) != true && new_coordinates_occupied_by_opponent?(top_left_diagonally_of_current_coordinates) == true
          capturable_opponent_coordinates.append(top_left_diagonally_of_current_coordinates)
        end
        if new_coordinates_occupied_by_same_team?(selected_piece, top_right_diagonally_of_current_coordinates) != true && new_coordinates_occupied_by_opponent?(top_right_diagonally_of_current_coordinates) == true
          capturable_opponent_coordinates.append(top_right_diagonally_of_current_coordinates)
        end
      end
    end

    if selected_piece.team == 'Black'
      bottom_left_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] - 1, copy_of_current_coordinates[1] - 1]
      bottom_right_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] - 1, copy_of_current_coordinates[1] + 1]
      if @board.board[bottom_left_diagonally_of_current_coordinates[0]][bottom_left_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, bottom_left_diagonally_of_current_coordinates) != true && new_coordinates_occupied_by_opponent?(bottom_left_diagonally_of_current_coordinates)
          capturable_opponent_coordinates.append(bottom_left_diagonally_of_current_coordinates)
        end
      end
      if @board.board[bottom_right_diagonally_of_current_coordinates[0]][bottom_right_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, bottom_right_diagonally_of_current_coordinates) != true && new_coordinates_occupied_by_opponent?(bottom_right_diagonally_of_current_coordinates)
          capturable_opponent_coordinates.append(bottom_right_diagonally_of_current_coordinates)
        end
      end
    end
    capturable_opponent_coordinates
  end

  def piece_between_rook(selected_piece)
    occupied_coordinates = []
    copy_of_current_coordinates = selected_piece.location.clone

    if copy_of_current_coordinates[0] != 7
      temporary_copy_of_current_coordinates_one = copy_of_current_coordinates.clone
      until temporary_copy_of_current_coordinates_one[0] == 7
        temporary_copy_of_current_coordinates_one[0] += 1
        if @board.board[temporary_copy_of_current_coordinates_one[0]][temporary_copy_of_current_coordinates_one[1]] != ' '
          black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
          white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_one[0] += 1
            end
          end
          if selected_piece.team == 'Black'
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
            if white_index != nil
              temporary_copy_of_current_coordinates_one[0] += 1
            end
          end
          
          occupied_coordinates.append([temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]])

          until temporary_copy_of_current_coordinates_one[0] == 7
            temporary_copy_of_current_coordinates_one[0] += 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[0] > -1
      temporary_copy_of_current_coordinates_two = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_two[0] > -1
        temporary_copy_of_current_coordinates_two[0] -= 1
        if @board.board[temporary_copy_of_current_coordinates_two[0]][temporary_copy_of_current_coordinates_two[1]] != ' '
          black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]] }
          white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]] }
          if selected_piece.team == 'White'
            if black_index != nil
              temporary_copy_of_current_coordinates_two[0] -= 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_two[0] -= 1
            end
          end

          occupied_coordinates.append([temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]])

          while temporary_copy_of_current_coordinates_two[0] > -1
            temporary_copy_of_current_coordinates_two[0] -= 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[1] != 7
      temporary_copy_of_current_coordinates_three = copy_of_current_coordinates.clone
      until temporary_copy_of_current_coordinates_three[1] == 7
        temporary_copy_of_current_coordinates_three[1] += 1
        if @board.board[temporary_copy_of_current_coordinates_three[0]][temporary_copy_of_current_coordinates_three[1]] != ' '
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]] }
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_three[1] += 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_three[1] += 1
            end
          end
          
          occupied_coordinates.append([temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]])
          
          until temporary_copy_of_current_coordinates_three[1] == 7
            temporary_copy_of_current_coordinates_three[1] += 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[1] > -1
      temporary_copy_of_current_coordinates_four = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_four[1] > -1
        temporary_copy_of_current_coordinates_four[1] -= 1
        if @board.board[temporary_copy_of_current_coordinates_four[0]][temporary_copy_of_current_coordinates_four[1]] != ' '
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]] }
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_four[1] -= 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_four[1] -= 1
            end
          end

          occupied_coordinates.append([temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]])
          
          while temporary_copy_of_current_coordinates_four[1] > -1
            temporary_copy_of_current_coordinates_four[1] -= 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]])
          end
        end
      end
    end
    occupied_coordinates
  end

  def piece_between_bishop(selected_piece)
    occupied_coordinates = []
    copy_of_current_coordinates = selected_piece.location.clone

    if copy_of_current_coordinates[0] < 7 && copy_of_current_coordinates[1] > -1
      temporary_copy_of_current_coordinates_one = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_one[0] < 7 && temporary_copy_of_current_coordinates_one[1] > -1
        temporary_copy_of_current_coordinates_one[0] += 1
        temporary_copy_of_current_coordinates_one[1] -= 1
        if @board.board[temporary_copy_of_current_coordinates_one[0]][temporary_copy_of_current_coordinates_one[1]] != ' '
          black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
          white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]] }
          if selected_piece.team == 'White'
            if black_index != nil
              temporary_copy_of_current_coordinates_one[0] += 1
              temporary_copy_of_current_coordinates_one[1] -= 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_one[0] += 1
              temporary_copy_of_current_coordinates_one[1] -= 1
            end
          end
          occupied_coordinates.append([temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]])
          while temporary_copy_of_current_coordinates_one[0] < 7 && temporary_copy_of_current_coordinates_one[1] > -1
            temporary_copy_of_current_coordinates_one[0] += 1
            temporary_copy_of_current_coordinates_one[1] -= 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_one[0], temporary_copy_of_current_coordinates_one[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[0] < 7 && copy_of_current_coordinates[1] < 7
      temporary_copy_of_current_coordinates_two = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_two[0] < 7 && temporary_copy_of_current_coordinates_two[1] < 7
        temporary_copy_of_current_coordinates_two[0] += 1
        temporary_copy_of_current_coordinates_two[1] += 1
        if @board.board[temporary_copy_of_current_coordinates_two[0]][temporary_copy_of_current_coordinates_two[1]] != ' '
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]] }
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_two[0] += 1
              temporary_copy_of_current_coordinates_two[1] += 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_two[0] += 1
              temporary_copy_of_current_coordinates_two[1] += 1
            end
          end
          occupied_coordinates.append([temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]])
          while temporary_copy_of_current_coordinates_two[0] < 7 && temporary_copy_of_current_coordinates_two[1] < 7
            temporary_copy_of_current_coordinates_two[0] += 1
            temporary_copy_of_current_coordinates_two[1] += 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_two[0], temporary_copy_of_current_coordinates_two[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[0] > -1 && copy_of_current_coordinates[1] > -1
      temporary_copy_of_current_coordinates_three = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_three[0] > -1 && temporary_copy_of_current_coordinates_three[1] > -1
        temporary_copy_of_current_coordinates_three[0] -= 1
        temporary_copy_of_current_coordinates_three[1] -= 1
        if @board.board[temporary_copy_of_current_coordinates_three[0]][temporary_copy_of_current_coordinates_three[1]] != ' '
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]] }
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_three[0] -= 1
              temporary_copy_of_current_coordinates_three[1] -= 1
            end
          end
          if selected_piece.team == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_three[0] -= 1
              temporary_copy_of_current_coordinates_three[1] -= 1
            end
          end
          occupied_coordinates.append([temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]])
          while temporary_copy_of_current_coordinates_three[0] > -1 && temporary_copy_of_current_coordinates_three[1] > -1
            temporary_copy_of_current_coordinates_three[0] -= 1
            temporary_copy_of_current_coordinates_three[1] -= 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_three[0], temporary_copy_of_current_coordinates_three[1]])
          end
        end
      end
    end

    if copy_of_current_coordinates[0] > -1 && copy_of_current_coordinates[1] < 7
      temporary_copy_of_current_coordinates_four = copy_of_current_coordinates.clone
      while temporary_copy_of_current_coordinates_four[0] > -1 && temporary_copy_of_current_coordinates_four[1] < 7
        temporary_copy_of_current_coordinates_four[0] -= 1
        temporary_copy_of_current_coordinates_four[1] += 1
        if @board.board[temporary_copy_of_current_coordinates_four[0]][temporary_copy_of_current_coordinates_four[1]] != ' '
          if selected_piece.team == 'White'
            black_index = @board.black_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]] }
            white_index = @board.white_player.find_index { |unit| unit.location == [temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]] }
            if black_index != nil
              temporary_copy_of_current_coordinates_four[0] -= 1
              temporary_copy_of_current_coordinates_four[1] += 1
            end
          end
          if selected_piece.type == 'Black'
            if white_index != nil
              temporary_copy_of_current_coordinates_four[0] -= 1
              temporary_copy_of_current_coordinates_four[1] += 1
            end
          end
          occupied_coordinates.append([temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]])
          while temporary_copy_of_current_coordinates_four[0] > -1 && temporary_copy_of_current_coordinates_four[1] < 7
            temporary_copy_of_current_coordinates_four[0] -= 1
            temporary_copy_of_current_coordinates_four[1] += 1
            occupied_coordinates.append([temporary_copy_of_current_coordinates_four[0], temporary_copy_of_current_coordinates_four[1]])
          end
        end
      end
    end
    occupied_coordinates
  end

  def piece_between_queen(selected_piece)
    occupied_coordinates = []
    occupied_coordinates = occupied_coordinates + piece_between_rook(selected_piece)
    occupied_coordinates = occupied_coordinates + piece_between_bishop(selected_piece)
    occupied_coordinates
  end

  def piece_infront_king(selected_piece)
    occupied_coordinates = []
    copy_of_current_coordinates = selected_piece.location.clone

    top_left_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] + 1, copy_of_current_coordinates[1] - 1]
    
    if top_left_diagonally_of_current_coordinates[0] <= 7 && top_left_diagonally_of_current_coordinates[1] >= 0
      if @board.board[top_left_diagonally_of_current_coordinates[0]][top_left_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, top_left_diagonally_of_current_coordinates) == true
          occupied_coordinates.append(top_left_diagonally_of_current_coordinates)
        end
      end
    end

    top_of_current_coordinates = [copy_of_current_coordinates[0] + 1, copy_of_current_coordinates[1]]

    if top_of_current_coordinates[0] <= 7
      if @board.board[top_of_current_coordinates[0]][top_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, top_of_current_coordinates) == true
          occupied_coordinates.append(top_of_current_coordinates)
        end
      end
    end

    top_right_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] + 1, copy_of_current_coordinates[1] + 1]
    
    if top_right_diagonally_of_current_coordinates[0] <= 7 && top_right_diagonally_of_current_coordinates[1] <= 7
      if @board.board[top_right_diagonally_of_current_coordinates[0]][top_right_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, top_right_diagonally_of_current_coordinates) == true
          occupied_coordinates.append(top_right_diagonally_of_current_coordinates)
        end
      end
    end

    left_of_current_coordinates = [copy_of_current_coordinates[0], copy_of_current_coordinates[1] - 1]

    if left_of_current_coordinates[1] >= 0
      if @board.board[left_of_current_coordinates[0]][left_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, left_of_current_coordinates) == true
          occupied_coordinates.append(left_of_current_coordinates)
        end
      end
    end

    right_of_current_coordinates = [copy_of_current_coordinates[0], copy_of_current_coordinates[1] + 1]

    if right_of_current_coordinates[1] <= 7
      if @board.board[right_of_current_coordinates[0]][right_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, right_of_current_coordinates) == true
          occupied_coordinates.append(right_of_current_coordinates)
        end
      end
    end

    bottom_left_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] - 1, copy_of_current_coordinates[1] - 1]

    if bottom_left_diagonally_of_current_coordinates[0] >= 0 && bottom_left_diagonally_of_current_coordinates[1] >= 1
      if @board.board[bottom_left_diagonally_of_current_coordinates[0]][bottom_left_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, bottom_left_diagonally_of_current_coordinates) == true
          occupied_coordinates.append(bottom_left_diagonally_of_current_coordinates)
        end
      end
    end

    bottom_of_current_coordinates = [copy_of_current_coordinates[0] - 1, copy_of_current_coordinates[1]]

    if bottom_of_current_coordinates[0] >= 0
      if @board.board[bottom_of_current_coordinates[0]][bottom_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, bottom_of_current_coordinates) == true
          occupied_coordinates.append(bottom_of_current_coordinates)
        end
      end
    end

    bottom_right_diagonally_of_current_coordinates = [copy_of_current_coordinates[0] - 1, copy_of_current_coordinates[1] + 1]

    if bottom_right_diagonally_of_current_coordinates[0] >= 0 && bottom_right_diagonally_of_current_coordinates[1] <= 7
      if @board.board[bottom_right_diagonally_of_current_coordinates[0]][bottom_right_diagonally_of_current_coordinates[1]] != ' '
        if new_coordinates_occupied_by_same_team?(selected_piece, bottom_right_diagonally_of_current_coordinates) == true
          occupied_coordinates.append(bottom_right_diagonally_of_current_coordinates)
        end
      end
    end

    occupied_coordinates
  end

  def king_is_checked?()
    # Check at the start of every turn if the Player's King is Checked
    if current_player() == 'White'
      black_king_index = @board.black_player.find_index { |unit| unit.type == '♚' }
      black_king = @board.black_player[black_king_index]
      black_king_location = black_king.location
      @board.white_player.each do |white_piece|
        return true if valid_new_coordinates?(white_piece, black_king_location) == true
      end
    end
    
    if current_player() == 'Black'
      white_king_index = @board.white_player.find_index { |unit| unit.type == '♚' }
      white_king = @board.white_player[white_king_index]
      white_king_location = white_king.location
      @board.black_player.each do |black_piece|
        return true if valid_new_coordinates?(black_piece, black_king_location) == true
      end
    end
  end

  def king_is_checkmated?()
    # Generate a list of possible positions the king is able to move to
    # Based on the possible positions, create a list of legal moves the king is able to move to
    if current_player() == 'White'
      checked_coordinates = []
      black_king_index = @board.black_player.find_index { |unit| unit.type == '♚' }
      black_king = @board.black_player[black_king_index]
      black_king_possible_positions = black_king.possible_positions
      occupied_coordinates = piece_infront_king(black_king)
      occupied_coordinates.each do |occupied_coordinate|
        next if black_king_possible_positions.include?(occupied_coordinate) != true
        temporary_index = black_king_possible_positions.find_index { |possible_position| possible_position == occupied_coordinate }
        black_king_possible_positions.delete_at(temporary_index)
      end
      
      black_king_original_position = black_king.location.clone

      black_king_possible_positions.each do |black_king_coordinates|
        @board.board[black_king_original_position[0]][black_king_original_position[1]] = ' '
        if @board.board[black_king_coordinates[0]][black_king_coordinates[1]] != ' '
          temporary_piece = @board.board[black_king_coordinates[0]][black_king_coordinates[1]].clone
          @board.board[black_king_coordinates[0]][black_king_coordinates[1]] = ' '
        end
        black_king.location = black_king_coordinates
        @board.board[black_king_coordinates[0]][black_king_coordinates[1]] = black_king.type.black
        @board.white_player.each do |white_piece|
          if valid_new_coordinates?(white_piece, black_king_coordinates) == true
            checked_coordinates.append(black_king_coordinates)
          end              
        end
        if temporary_piece != nil
          @board.board[black_king_coordinates[0]][black_king_coordinates[1]] = temporary_piece
        else
          @board.board[black_king_coordinates[0]][black_king_coordinates[1]] = ' '
        end
        @board.board[black_king_original_position[0]][black_king_original_position[1]] = black_king.type.black
        black_king.location = black_king_original_position
      end

      black_king_possible_positions = black_king_possible_positions - checked_coordinates

      p black_king_possible_positions

      return false if black_king_possible_positions.empty? != true
      return true if black_king_possible_positions.empty? == true
    end

    if current_player() == 'Black'
      checked_coordinates = []
      white_king_index = @board.white_player.find_index { |unit| unit.type == '♚' }
      white_king = @board.white_player[white_king_index]
      white_king_possible_positions = white_king.possible_positions
      occupied_coordinates = piece_infront_king(white_king)
      occupied_coordinates.each do |occupied_coordinate|
        white_king_possible_positions = white_king_possible_positions - occupied_coordinate
      end

      white_king_original_position = white_king.location.clone

      white_king_possible_positions.each do |white_king_coordinates|
        @board.board[white_king_original_position[0]][white_king_original_position[1]] = ' '
        if @board.board[white_king_coordinates[0]][white_king_coordinates[1]] != ' '
          temporary_piece = @board.board[white_king_coordinates[0]][white_king_coordinates[1]].clone
        end
        white_king.location = white_king_coordinates
        @board.board[white_king_coordinates[0]][white_king_coordinates[1]] = white_king.type.white
        @board.black_player.each do |black_piece|
          if valid_new_coordinates?(black_piece, white_king_coordinates) == true
            checked_coordinates.append(white_king_coordinates)
          end
        end
        if temporary_piece != nil
          @board.board[white_king_coordinates[0]][white_king_coordinates[1]] = temporary_piece
        else
          @board.board[white_king_coordinates[0]][white_king_coordinates[1]] = ' '
        end
        @board.board[white_king_original_position[0]][white_king_original_position[1]] = white_king.type.white
        white_king.location = white_king_original_position
      end

      white_king_possible_positions = white_king_possible_positions - checked_coordinates

      return false if white_king_possible_positions.empty? != true
      return true if white_king_possible_positions.empty? == true
    end
  end
end


test = NewGame.new
p test.two_player_game
