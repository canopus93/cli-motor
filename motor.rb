load 'steer_engine.rb'
load 'spedo_meter_engine.rb'
class Motor
	include SpedoMeterEngine
	include SteerEngine
	require 'bigdecimal'
	require 'bigdecimal/util'

	attr_accessor :name, :max_fuel_capacity, :velocity, :time_travelled, :distance_travelled, :current_fuel, :space, :price, :type

	WHEELS = 2
	@@motors = []

	def initialize(name:, max_fuel_capacity:, velocity:, space:, price:)
		@name = name
		@max_fuel_capacity = set_decimal(max_fuel_capacity)
		@velocity = set_decimal(velocity)
		@space = space
		@price = price
		set_default
		@@motors << self
	end

	def self.create(name:, max_fuel_capacity:, velocity:, space:, price:)
		self.new(name: name, max_fuel_capacity: max_fuel_capacity, velocity: velocity, space: space, price: price)
	end

	def self.all
		@@motors
	end

	def self.find(category)
		where(category).first
	end

	def self.where(category)
		result = @@motors
		category.each do |key, value|
			result = result.select { |motor| motor.send(key) == value }
		end
		result
	end

	def self.destroy(index)
		@@motors.delete_at(index)
	end

	def self.delete(motor_to_delete)
		@@motors.delete_if {|motor| motor == motor_to_delete}
	end

	def show_velocity
		@velocity.to_digits.to_s + ' M/s'
	end

	def show_fuel_capacity
		@max_fuel_capacity.to_digits.to_s + ' litre'
	end

	def fuel_refill(refill_amount)
		refill_amount_decimal = set_decimal(refill_amount)
		fuel_after_refill = @current_fuel + refill_amount_decimal
		if (@current_fuel == @max_fuel_capacity)
			print 'You cannot refill the fuel because current fuel is already full.'
		elsif (fuel_after_refill > @max_fuel_capacity)
			refilled_by = @max_fuel_capacity - @current_fuel
			@current_fuel = set_decimal(@max_fuel_capacity)
			print "Fuel is only refilled by #{refilled_by.to_digits} l. Current fuel has reached max capacity."
		else
			@current_fuel = fuel_after_refill
			print "Fuel is refilled by #{refill_amount_decimal.to_digits} l. Current fuel is #{@current_fuel.to_digits} l."
		end
		gets.chomp
	end

	def run(time)
		distance = set_decimal(@velocity) * time
		fuel_used = distance / 100
		if(fuel_used >= @current_fuel)
			fuel_used = @current_fuel
			@current_fuel = set_decimal(0)
			distance = fuel_used * 100
			time = distance / @velocity
		else
			@current_fuel -= fuel_used
		end
		@distance_travelled += distance
		@time_travelled += time

		result = [time, distance]
	end

	def reset_motor
		answer = ''
		until (answer == 'yes' || answer == 'no') do
			print 'Do you want to reset motor? [yes/no] : '
			answer = gets.chomp
		end
		if (answer == 'yes')
			set_default
			print 'Motor has been reseted.'
			gets.chomp
		end
	end

	def set_default
		@current_fuel = set_decimal(0)
		@distance_travelled = set_decimal(0)
		@time_travelled = set_decimal(0)
		@type = 'motor'
	end

	def set_decimal(number)
		result = BigDecimal.new(number.to_s)
	end
end