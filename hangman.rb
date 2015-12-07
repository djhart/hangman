require 'yaml'
dictionary = File.readlines 'dictionary.txt'
dictionary.map! {|a| a.downcase.gsub!(/\W/,'') }
dictionary.delete_if {|a| a.length < 6 || a.length > 12} # includes extra \n char
n = dictionary.length

class Game
	attr_reader :word, :hangman
	attr_accessor :guess, :fail_count, :guesses, :yaml, :game_file
	def initialize(word)
		@word = word
		@guess = Array.new(word.length, "_ ")
		@guesses = []
		@hangman = ["_______","____\n|  |\n|\n|\n|\n|_____\n_______","____\n|  |\n|  0\n|\n|\n|_____\n_______","____\n|  |\n|  0\n|  |\\\n|\n|_____\n_______","____\n|  |\n|  0\n| /|\\\n|\n|_____\n_______","____\n|  |\n|  0\n| /|\\\n|   \\\n|_____\n_______","____\n|  |\n|  0\n| /|\\\n| / \\\n|_____\n_______"]
		@fail_count = 0
	end

	def save_game
		yaml = YAML.dump(self)
		game_file = File.new("my_game.yaml","w")
		game_file.write(yaml)
	end

	def load_game
		game_file = File.new("my_game.yaml","r")
		yaml = game_file.read
		YAML.load(yaml)
	end

	def display
		puts @hangman[@fail_count]
		@guess.each {|a| print a}
		puts ""
		print "guesses:"
		@guesses.each {|a| print a}
		puts ""
	end

	def turn(check)
		char = 0 
		until check.include?(char) || char == "save" || char == "load"
			puts "your guess? Type save to save"
			char = gets.chomp.downcase

			if char ==  "save"
				self.save_game			
			else						
				@guesses << char 
				@word.each_char.with_index{|a,n| @guess[n] = char if a == char}
				@fail_count += 1 unless @guess.include?(char) || @guesses.include?(char)
			end
		end		
	end

	def over?
		#(@fail_count == 5 || !(@guess.include?("_"))) ? true : false
		@fail_count == 6 || @word == @guess.join ? true : false
	end

	def finish
		puts "you lose" if @fail_count == 6 
		puts "you win!" if @word == @guess.join
	end
end

check = ('a'..'z')
game = Game.new(dictionary[rand(n)])

puts "load? \nY/N"
ans = gets.chomp.downcase 
if ans == "y" 
	game = game.load_game
end

until game.over?
	game.display
	game.turn(check)
end

game.display
puts "#{game.word.upcase}"
game.finish