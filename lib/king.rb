class King
  attr_accessor :moved, :location, :team, :type

  def initialize(location, team)
    @moved = false
    @location = location
    @team = team
    @type = '♚'
  end

  KING_MOVES =
  [
    [1, -1], [1, 0], [1, 1], [0, -1], 
    [0, 1], [-1, -1], [-1, 0], [-1, 1]
  ]

  def possible_positions
    possible_positions = []
    KING_MOVES.each do |move|
      new_location = move.zip(@location).map { |x, y| x + y if (x + y).between?(0, 7) }
      possible_positions << new_location unless new_location.include?(nil)
    end
    possible_positions
  end
end
