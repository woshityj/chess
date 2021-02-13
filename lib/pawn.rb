class Pawn
  attr_accessor :moved, :location, :type, :pawn_number, :team

  def initialize(location, pawn_number, team)
    @moved = false
    @location = location
    @type = '♟'
    @pawn_number = pawn_number
    @team = team
  end

  def possible_positions
    possible_positions = []
    x_move = [1, 2]
    current_location = @location
    x_move.each do |x|
      new_location = current_location[0] + x
      possible_positions << [new_location, current_location[1]]
    end
    possible_positions
  end
end
