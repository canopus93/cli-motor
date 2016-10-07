class CliMotor
	load 'motor.rb'
	load 'menu_vehicle.rb'
	include MenuVehicle

	def initialize
		menu_motor
	end

	def menu_motor
		option = ''

		until option == 'exit' do
			system 'clear'
			puts '-- Menu --'
			puts '1. Create Motor'
			puts '2. View All Motor'
			puts '3. Select Motor'
			print 'Choose option number [type \'exit\' to stop] : '
			option = gets.chomp
			
			case option
			when '1'
				system 'clear'
				puts '-- Create Motor --'
				result = create_vehicle(type: 'motor')
				new_vehicle = Motor.create(name: result[:name], max_fuel_capacity: result[:max_fuel_capacity], velocity: result[:velocity], space: result[:space].to_i, price: result[:price].to_i)
				print 'Success create new motor.'
				gets.chomp
			when '2'
				show_vehicle(vehicles: Motor.where(type: 'motor'))
				gets.chomp
			when '3'
				vehicle_to_choose = ''
				vehicles = Motor.where(type: 'motor')
				vehicle_count = vehicles.count
				until ((is_number?(vehicle_to_choose) && vehicle_to_choose.to_i <= vehicle_count && vehicle_to_choose.to_i > 0) || vehicle_to_choose == 'exit')
					show_vehicle(vehicles: vehicles)
					print "Choose motor by number [type 'exit' to back] : "
					vehicle_to_choose = gets.chomp
				end
				if (vehicle_to_choose != 'exit')
					index = vehicle_to_choose.to_i - 1
					vehicle = vehicles[index]
					
					print "You have chosen #{vehicle.name}."
					gets.chomp
					menu_operate_vehicle(vehicle: vehicle, index: index)
				end
			end
		end
	end

	def menu_operate_vehicle(vehicle:, index:)
		option_operate_vehicle = 0

		until option_operate_vehicle == 'exit' do
			system 'clear'
			puts "-- Menu Motor --"
			puts '1. Display Details'
			puts '2. Refill Fuel'
			puts "3. Run Motor"
			puts "4. Change Motor Name"
			puts '5. Change Velocity'
			puts '6. Change Fuel Capacity'
			puts '7. Reset Status'
			puts '8. Destroy Motor'
			puts '9. Press Horn'
			print 'Choose option number [type \'exit\' to stop] : '
			option_operate_vehicle = gets.chomp

			case option_operate_vehicle
			when '1'
				show_vehicle_details(name: vehicle.name, current_fuel: vehicle.current_fuel.to_digits, fuel_capacity: vehicle.max_fuel_capacity.to_digits, velocity: vehicle.show_velocity, time_travelled: vehicle.time_travelled.to_digits, distance_travelled: vehicle.distance_travelled.to_digits, type: vehicle.type)
			when '2'
				refill_amount = get_refill_amount
				vehicle.fuel_refill(refill_amount) if is_number?(refill_amount)
			when '3'
				run_time = get_run_time(vehicle_fuel: vehicle.current_fuel)
				if is_number?(run_time)
					result = vehicle.run(BigDecimal.new(run_time))
					print "Motor run for #{result[0].to_digits} s and reached #{result[1].to_digits} M."
					gets.chomp
				end
			when '4'
				vehicle.name = get_new_name(name: vehicle.name, type: vehicle.type)
			when '5'
				new_velocity = get_new_velocity(current_velocity: vehicle.velocity.to_digits)
				if is_number?(new_velocity)
					vehicle.velocity = BigDecimal.new(new_velocity)
					print 'Success edit velocity.'
					gets.chomp
				end
			when '6'
				new_fuel_capacity = get_new_fuel_capacity(current_fuel_capacity: vehicle.max_fuel_capacity.to_digits)
				if is_number?(new_fuel_capacity)
					new_fuel_capacity = BigDecimal.new(new_fuel_capacity)
					if(vehicle.current_fuel > new_fuel_capacity)
						vehicle.current_fuel = new_fuel_capacity
					end
					vehicle.max_fuel_capacity = new_fuel_capacity
					print 'Success edit max fuel capacity.'
					gets.chomp
				end
			when '7'
				vehicle.reset_motor
			when '8'
				option_operate_vehicle = delete_vehicle(vehicle: vehicle)
			when '9'
				vehicle.press_horn
			end
		end
	end

	def delete_vehicle(vehicle:)
		sell_confirmation = ''
		until(sell_confirmation == 'yes' || sell_confirmation == 'no')
			print "Are you sure to delete #{vehicle.name}? [yes/no] : "
			sell_confirmation = gets.chomp
		end
		if sell_confirmation == 'yes'
			Motor.delete(vehicle)
			print "Success delete #{vehicle.name}."
			gets.chomp
			'exit'
		end
	end
end
CliMotor.new