load 'motor.rb'
class SportMotor < Motor
	attr_accessor :type, :gear, :max_gear, :default_velocity

	def initialize(name:, type:)
		if type_checker(type)
			@name = name
			@type = type
			if type > 150
				@max_gear = 5
			else
				@max_gear = 4
			end
			@max_fuel_capacity = type/10
			set_default
			@@motors << self
		else
			print 'Cannot create Sport Motor, unidentified type.'
			gets.chomp
		end
	end

	def self.create(name:, type:)
		self.new(name: name, type: type)
	end

	def change_gear(gear)
		if(gear > @max_gear || gear < 1)
			print "Cannot change gear. Max gear is #{@max_gear}."
		elsif gear == @gear
			print "Nothing happened. Current gear is already #{@gear}."
		else
			@gear = gear
			@velocity = @default_velocity + (gear-1) * 5
			print "Success change gear. Current gear is now #{@gear}."
		end
		gets.chomp
	end

	def type_checker(type)
		if type == 110
			@default_velocity = 20
		elsif type == 120
			@default_velocity = 40
		elsif type == 250
			@default_velocity = 60
		elsif type == 300
			@default_velocity = 70
		else
			false
		end
		@default_velocity = set_decimal(@default_velocity)/3.6
	end

	def set_default
		super
		@velocity = set_decimal(@default_velocity)
		@gear = 1
	end
end