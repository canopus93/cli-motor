load 'motor.rb'
class Car < Motor
	WHEELS = 4

	def set_default
		super
		@type = 'car'
	end
end