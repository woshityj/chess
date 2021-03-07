class Pawn
  attr_accessor :moved, :location, :type, :team, :points

  def initialize(location, team)
    @moved = false
    @location = location
    @type = '♟'
    @team = team
    @points = 1
  end

  def possible_positions
    possible_positions = []
    x_move = [1, 2]
    current_location = @location
    if @team == 'White'
      x_move.each do |x|
        new_location = current_location[0] + x
        possible_positions << [new_location, current_location[1]]
      end
    end
    if @team == 'Black'
      x_move.each do |x|
        new_location = current_location[0] - x
        possible_positions << [new_location, current_location[1]]
      end
    end
    possible_positions
  end
end
