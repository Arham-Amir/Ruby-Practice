class TicTacToe
  def initialize
    @blocks = (1..9).to_a
    @turn = 0
    @player1_sign = "X"
    @player2_sign = "O"
  end

  def getTurn
    return @turn
  end

  def toss
    system "cls"
    @turn = rand(2) + 1
    puts "\t\t***  Player #{@turn} gets first turn  ***"
    displayBlocks
  end

  def printTurn
    puts "\t\t***  Player #{@turn} turn  ***"
  end

  def checkValue(i)
    return @blocks[i-1]
  end

  def setValue(i)
    system "cls"
    @blocks[i-1] = @turn == 1? @player1_sign : @player2_sign
    @turn = @turn == 1? 2 : 1
    printTurn
    displayBlocks
  end

  def check_win
    win_combinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], # Horizontal
      [0, 3, 6], [1, 4, 7], [2, 5, 8], # Vertical
      [0, 4, 8], [2, 4, 6]             # Diagonal
    ]

    win_combinations.each do |combo|
      if @blocks[combo[0]] == @blocks[combo[1]] && @blocks[combo[1]] == @blocks[combo[2]]
        return @blocks[combo[0]]
      end
    end

    return nil
  end

  def draw
    @blocks.all? { |cell| cell == @player1_sign || cell == @player2_sign }
  end

  def displayBlocks
    puts "-------------"
    (0..2).each do |i|
      print "| "
      (0..2).each do |j|
        print @blocks[i * 3 + j]
        print " | "
      end
      puts
      puts "-------------"
    end
  end

end

def integerInput(game)
  loop do
    print "Enter Cell NO: "
    inpu = gets.chomp
    conversion = inpu.to_i
    if conversion.to_s == inpu && (conversion.between?(1,9))
      return conversion
    else
      system "cls"
      game.printTurn
      puts "Please enter a valid integer or integer between 1 to 9."
      game.displayBlocks
    end
  end
end

game = TicTacToe.new
game.toss
loop do
  choice = integerInput(game)
  game.setValue(choice)
  if game.check_win != nil
    puts "\n\t\t Hurray Player #{game.getTurn} wins the game. !!!!!!"
    return
  end
  if game.draw == true
    puts "\n\t\t Game Draw. Both player played very well !!!!!!"
    return
  end
end

