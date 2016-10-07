load 'motor.rb'
load 'car.rb'
class Garage
	attr_reader :max_garage_capacity, :current_capacity
	attr_writer :motors

	def initialize(max_garage_capacity:)
		@motors = []
		@max_garage_capacity = max_garage_capacity
		@current_capacity = 0
	end

	def add_motor(index: nil, motor: nil)
		if(motor == nil)
			result = Motor.all[index]
		elsif(index == nil)
			result = motor
		end			
		capacity_after_add = current_capacity + result.space
		if(capacity_after_add <= max_garage_capacity)
			@motors << result
			@current_capacity += result.space
		else
			false
		end
	end

	def view_all_motor
		@motors
	end

	def remove_motor(index)
		@current_capacity -= @motors[index].space
		@motors.delete_at(index)
	end

	def find_motor(category)
		result = @motors
		category.each do |key, value|
			result = result.select { |motor| motor.send(key) == value }
		end
		result.first
	end
end