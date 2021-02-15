class Knight
  attr_accessor :location, :knight_number, :team, :knight, :points

  def initialize(location, knight_number, team)
    @location = location
    @knight_number = knight_number
    @team = team
    @type = '♞'
    @points = 3
  end

  KNIGHT_MOVES =
  [
    [1, 2], [2, 1], [-1, 2], [-2, 1],
    [1, -2], [2, -1], [-1, -2], [-2, -1]
  ]

  def possible_positions
    possible_positions = []
    KNIGHT_MOVES.each do |move|
      new_location = move.zip(@location).map { |x, y| x + y if (x + y).between?(0, 7) }
      possible_positions << new_location unless new_location.include?(nil)
    end
    possible_positions
  end
end
