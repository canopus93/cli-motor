module MenuVehicle
	def is_number?(text)
		text.to_f.to_s == text.to_s || text.to_i.to_s == text.to_s
	end

	def show_vehicle(vehicles:)
		i = 0
		system 'clear'
		puts '-- List Vehicle --'
		puts '| No |       Name       | Fuel Capacity |  Velocity  | Space |   Price   |  Type  |'
		vehicles.each do |vehicle|
			printf "| %2s | %-16s | %11s l | %6s M/s | %5s | %9s | %-6s |\n", (i+1), vehicle.name, vehicle.max_fuel_capacity.to_digits, vehicle.velocity.to_digits, vehicle.space, vehicle.price, vehicle.type
			i+= 1
		end
	end

	def menu_operate_vehicles(vehicle:, index:, person: nil, type: nil)
		option_operate_vehicle = 0

		until (option_operate_vehicle == 'exit') do	
			system 'clear'
			show_menu_operate(person: person, type: type)
			print 'Choose option number [type \'exit\' to stop] : '
			option_operate_vehicle = gets.chomp

			case option_operate_vehicle
			when '1'
				show_vehicle_details(vehicle: vehicle)
			when '2'
				fuel_refill(vehicle: vehicle)
			when '3'
				run_vehicle(vehicle: vehicle)
			when '4'
				change_vehicle_name(vehicle: vehicle)
			when '5'
				change_vehicle_velocity(vehicle: vehicle)
			when '6'
				change_vehicle_fuel_capacity(vehicle: vehicle)
			when '7'
				vehicle.reset_motor
			when '8'
				delete_vehicle(vehicle: vehicle, person: person)
			when '9'
				vehicle.press_horn
			end
		end
	end

	def create_vehicle(type: nil)

		print 'Input Name : '
		name = gets.chomp

		max_fuel_capacity = ''
		until (is_number?(max_fuel_capacity))
			print 'Input Max Fuel Capacity : '
			max_fuel_capacity = gets.chomp
		end

		velocity = ''
		until (is_number?(velocity))
			print 'Input Velocity : '
			velocity = gets.chomp
		end

		space = ''
		until (is_number?(space))
			print 'Input Space : '
			space = gets.chomp
		end

		price = ''
		until (is_number?(price))
			print 'Input Price : '
			price = gets.chomp
		end

		if type == nil
			until (type == 'motor' || type == 'car')
				print 'Input Type [motor/car] : '
				type = gets.chomp
			end
		else
			type = type
		end

		result = {name: name, max_fuel_capacity: max_fuel_capacity, velocity: velocity, space: space, price: price, type: type}
	end

	def choose_vehicle(person: nil, type: nil)
		vehicle_to_choose = ''
		if person == nil
			if type == 'motor'
				result = Motor.where(type: 'motor')
			elsif type == 'car'
				result = Motor.where(type: 'car')
			end
			vehicle_count = result.count
		else
			vehicle_count = person.view_all_motor.count
			type = 'vehicle'
		end
		until ((is_number?(vehicle_to_choose) && vehicle_to_choose.to_i <= vehicle_count && vehicle_to_choose.to_i > 0) || vehicle_to_choose == 'exit')
			show_vehicle(person: person, type: type)
			print "Choose #{type} by number [type 'exit' to back] : "
			vehicle_to_choose = gets.chomp
		end
		if (vehicle_to_choose != 'exit')
			index = vehicle_to_choose.to_i - 1
			if person == nil
				vehicle = result[index]
			else
				vehicle = person.view_all_motor[index]
			end
			print "You have chosen #{vehicle.name}."
			gets.chomp
			menu_operate_vehicles(vehicle: vehicle, index: index, person: person, type: type)
		end
	end

	def show_menu_operate(person: nil, type: nil)
		if person == nil
			if type == 'motor'
				text_menu = 'Motor'
			elsif type == 'car'
				text_menu = 'Car'
			end
		else
			text_menu = 'Vehicle'
		end
		puts "-- Menu #{text_menu} --"
		puts '1. Display Details'
		puts '2. Refill Fuel'
		puts "3. Run #{text_menu}"
		puts "4. Change #{text_menu} Name"
		puts '5. Change Velocity'
		puts '6. Change Fuel Capacity'
		puts '7. Reset Status'
		if person == nil
			puts "8. Destroy #{text_menu}"
		else
			puts '8. Sell Motor'
		end
		puts '9. Press Horn'
	end

	def show_vehicle_details(name:, current_fuel:, fuel_capacity:, velocity:, time_travelled:, distance_travelled:, type:)
		system 'clear'
		if type == 'motor'
			puts '-- Motor Details --'
		else
			puts '-- Car Details --'
		end
		puts "Name               : #{name}"
		puts "Current Fuel       : #{current_fuel} l"
		puts "Fuel Capacity      : #{fuel_capacity} l"
		puts "Velocity           : #{velocity}"
		puts "Time Travelled     : #{time_travelled} s"
		puts "Distance Travelled : #{distance_travelled} M"
		print 'Press enter to continue ...'
		gets.chomp
	end

	def get_refill_amount
		fuel_amount = ''
		until(is_number?(fuel_amount) || fuel_amount == 'exit')
			print 'Input amount of fuel to fill in litre [type \'exit\' to back] : '
			fuel_amount = gets.chomp
		end
		fuel_amount
	end

	def get_run_time(vehicle_fuel:)
		run_time = ''
		if(vehicle_fuel > 0)
			until(is_number?(run_time) || run_time == 'exit')
				system 'clear'
				print 'Input amount of time to run in second [type \'exit\' to back] : '
				run_time = gets.chomp				
			end
		else
			print 'Vehicle does not have any fuel left, please refill the fuel.'
			gets.chomp
		end
		run_time
	end

	def get_new_name(name:, type:)
		puts "Current #{type} name is #{name}."
		print 'Input new name : '
		new_name = gets.chomp
		print "Success edit #{type} name."
		gets.chomp
		new_name
	end

	def get_new_velocity(current_velocity:)
		new_velocity = ''
		until(is_number?(new_velocity) || new_velocity == 'exit')
			puts "Current velocity is #{current_velocity} M/s."
			print 'Input new velocity [type \'exit\' to back] : '
			new_velocity = gets.chomp
		end
		new_velocity
	end

	def get_new_fuel_capacity(current_fuel_capacity:)
		new_fuel_capacity = ''
		until(is_number?(new_fuel_capacity) || new_fuel_capacity == 'exit')
			puts "Current fuel capacity is #{current_fuel_capacity} l"
			print 'Input new fuel capacity [type \'exit\' to back] : '
			new_fuel_capacity = gets.chomp
		end
		new_fuel_capacity
	end

	def delete_vehicle(vehicle:, index:, person: nil)
		choose_delete_vehicle = ''
		until(choose_delete_vehicle == 'yes' || choose_delete_vehicle == 'no')
			if person == nil
				print "Are you sure to delete #{vehicle.name}? [yes/no] : "
			else
				print "Are you sure to sell #{vehicle.name} for half the price? [yes/no] : "
			end
			choose_delete_vehicle = gets.chomp
		end
		if(choose_delete_vehicle == 'yes')
			if person == nil
				print "Success delete #{vehicle.type}."
				Motor.delete(vehicle)
			else
				person.remove_motor(index)
				print "Success sell #{vehicle.type} for half the price."
			end
			gets.chomp
			option_operate_vehicle = 'exit'
		end
	end
end