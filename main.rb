require_relative 'utils'

class Wasd2048
  FOUR = 4

  def initialize
    @board = Array.new(FOUR) { Array.new(FOUR) }
    new_num_popup!
    new_num_popup!
  end

  def stack_to_left
    @before_stack = Marshal.load( Marshal.dump(@board) )

    @board.map do |arr|
      arr.replace push_aside(arr)
      (0...FOUR).map { |idx| arr[idx..idx+1] = sum_or_skip(arr[idx..idx+1]) }
      arr.replace push_aside(arr)
    end

    new_num_popup?(@simulation)
    @board
  end

  def stack_to_right
    horrizontal_mirror!
    stack_to_left
    horrizontal_mirror!
  end

  def stack_to_top
    anticlock_rotate!
    stack_to_left
    clockwise_rotate!
  end

  def stack_to_bottom
    clockwise_rotate!
    stack_to_left
    anticlock_rotate!
  end

  def has_2048?
    !!@board.flatten.find { |f| f == 2048 }
  end

  def is_over?
    return false if @board.flatten.compact.count < FOUR * FOUR
    before_stack = Marshal.load( Marshal.dump(@board) )

    @simulation = true
    if stack_to_left != before_stack || stack_to_right != before_stack ||
     stack_to_bottom != before_stack || stack_to_top   != before_stack
      @board = before_stack
      @simulation = false
      return false
    else
      return true
    end
  end

  def show
    clear_screen!
    move_to_home!
    puts to_s
    puts
  end

  private

    def push_aside(arr)
      return arr if arr.compact.size == FOUR || arr.compact.none?
      arr.compact + Array.new( FOUR - arr.compact.size, nil )
    end

    def sum_or_skip(pair)
      return pair if pair.compact.size != 2
      pair.first == pair.last ? [pair.reduce(:+), nil] : pair
    end

    def new_num_popup?(skip = false)
      return nil if skip == true
      @before_stack == @board ? false : new_num_popup!
    end

    def horrizontal_mirror!
      @board.map { |arr| arr.reverse! }
    end

    def anticlock_rotate!
      horrizontal_mirror!
      @board = @board.transpose
    end

    def clockwise_rotate!
      anticlock_rotate!
      anticlock_rotate!
      anticlock_rotate!
    end

    def new_num_popup!
      loop do
        xy = rand(FOUR*FOUR).divmod(FOUR)
        break if @board[xy[0]][xy[1]].nil? && @board[xy[0]][xy[1]] = two_or_four
      end
    end

    def two_or_four
      2 + rand(2)*2
    end

    def to_s
      str = @board.map do |arr|
        arr.map { |chr| "____#{chr}"[-4..-1] }.join('|')
      end
      str.join("\n")
    end
end

game = Wasd2048.new
game.show

while true

  input = gets.chomp
  case input.downcase[-1]
  when 'w'
    game.stack_to_top
  when 'a'
    game.stack_to_left
  when 's'
    game.stack_to_bottom
  when 'd'
    game.stack_to_right
  when 'q'
    break
  else
    puts 'W(up)-A(left)-S(down)-D(right)-Q(quit)'
  end
  game.show

  if game.has_2048?
    puts 'YOU WIN'
    break
  elsif game.is_over?
    puts 'YOU LOSE'
    break
  end
end
