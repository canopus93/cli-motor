load 'garage.rb'
class Person
	attr_reader :garage, :motor, :name, :money
	attr_writer :name

	@@person = []

	def initialize(name:, max_garage_capacity:, money:)
		@name = name
		@money = money
		@garage = Garage.new(max_garage_capacity: max_garage_capacity)

		@@person << self
	end

	def self.all
		@@person
	end

	def self.destroy(index)
		@@person.delete_at(index)
	end

	def add_motor(motor)
		@garage.add_motor(motor: motor)
	end

	def buy_motor(index:, vehicle_price:)
		if @garage.add_motor(index: index)
			decrease_money(vehicle_price)
		else
			false
		end
	end

	def current_capacity
		@garage.current_capacity
	end

	def garage_capacity
		@garage.max_garage_capacity
	end

	def view_all_motor
		@garage.view_all_motor
	end

	def remove_motor(index)
		motor = @garage.view_all_motor[index]
		sell_price = motor.price / 2
		increase_money(sell_price)
		@garage.remove_motor(index)
	end

	def select_motor(category)
		@motor = @garage.find_motor(category)
	end

	def increase_money(amount)
		@money += amount
	end

	def decrease_money(amount)
		@money -= amount
	end
end