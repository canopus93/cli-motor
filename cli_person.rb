load 'menu_vehicle.rb'
class CliPerson
	load 'person.rb'
	include MenuVehicle
	require 'csv'
	require 'json'
	require 'bigdecimal'
	require 'bigdecimal/util'

	def initialize
		import_data
		menu
	end

	def set_velocity(velocity)
		result = velocity.split
		if result[1] == 'KM/h'
			result = BigDecimal.new(result[0])/3.6
			result = result.round(3)
		else
			result = BigDecimal.new(result[0])
		end
		result
	end

	def import_data
		motors = CSV.read('motor.csv', {headers: true, return_headers: false})
		motors.each do |motor|
			velocity = set_velocity(motor['velocity'])
			if motor['type'] == 'motor'
				Motor.create(name: motor['motor_name'], max_fuel_capacity: motor['max_fuel'].split[0], velocity: velocity, space: motor['space'].to_i, price: motor['price'].split[0].to_i)
			else
				Car.create(name: motor['motor_name'], max_fuel_capacity: motor['max_fuel'].split[0], velocity: velocity, space: motor['space'].to_i, price: motor['price'].split[0].to_i)
			end
		end

		file_person = File.read('people.json')
		persons = JSON.parse(file_person)
		persons.each do |person|
			Person.new(name: person['name'], max_garage_capacity: person['garage']['capacity'].to_i, money: person['money'].to_i)
			unless person['garage']['motor'].empty?
				current_person = Person.all.last
				motor_list = person['garage']['motor']
				motor_list.each do |motor|
					velocity = set_velocity(motor['velocity'])
					motor_to_add = Motor.find(name: motor['name'], type: motor['type'], price: motor['price'].to_i, space: motor['space'].to_i)
					if motor_to_add.nil?
						if motor['type'] == 'motor'
							motor_to_add = Motor.new(name: motor['name'], max_fuel_capacity: motor['max_fuel'].split[0], velocity: velocity, price: motor['price'].to_i, space: motor['space'].to_i)
						else
							motor_to_add = Car.new(name: motor['name'], max_fuel_capacity: motor['max_fuel'].split[0], velocity: velocity, price: motor['price'].to_i, space: motor['space'].to_i)
						end
					end
					current_person.add_motor(motor_to_add)
				end
			end
		end
	end

	# persons = CSV.read('people.csv')[1..-1]
	# persons = CSV.read('people.csv', {headers: true, return_headers: false})
	
	# persons.each do |person|
	# 	Person.new(name: person['name'], max_garage_capacity: person['garage_capacity'].to_i, money: person['money'].to_i)
	# end

	# file_motor = File.read('motor.json')
	# motors = JSON.parse(file_motor)
	# motors.each do |motor|
	# 	Motor.create(name: motor['motor_name'], max_fuel_capacity: motor['engine']['max_fuel'].split[0], velocity: motor['engine']['velocity'].split[0].to_i, space: motor['space'].to_i, price: motor['price'].to_i)
	# end

	def menu
		option = ''

		until (option == 'exit') do
			system 'clear'
			puts 'Menu'
			puts '1. Create Person'
			puts '2. View All Person'
			puts '3. Select Person'
			puts '4. Export Person'
			puts '5. Export Motor'
			print 'Choose option number [type \'exit\' to stop] : '
			option = gets.chomp

			case option
			when '1'
				system 'clear'
				puts '-- Create Person --'
				print 'Input Person Name : '
				name = gets.chomp
				max_garage_capacity = ''
				until (is_number?(max_garage_capacity))
					print 'Input Garage Capacity : '
					max_garage_capacity = gets.chomp
				end
				money = ''
				until (is_number?(money))
					print 'Input Money : '
					money = gets.chomp
				end
				Person.new(name: name, max_garage_capacity: max_garage_capacity.to_i, money: money.to_i)
				print 'Success create new person.'
				gets.chomp
			when '2'
				show_person
				gets.chomp
			when '3'
				choose_person = ''
				until ((is_number?(choose_person) && choose_person.to_i <= Person.all.count && choose_person.to_i > 0) || choose_person == 'exit')
					show_person
					print 'Choose person by number [type \'exit\' to back] : '
					choose_person = gets.chomp
				end
				if(choose_person != 'exit')
					index_person = choose_person.to_i - 1
					person = Person.all[index_person]
					print "You have chosen #{person.name}."
					gets.chomp
					vehicle_menu(person: person, index_person: index_person)
					person = ''
					choose_person = ''
				end
			when '4'
				File.open("test_person.json", "w") do |f|
					f.write(JSON.pretty_generate(person_to_export))
				end
				print 'Success export Person to JSON file.'
				gets.chomp
			when '5'
				CSV.open('test_motor.csv', 'w') do |csv|
					csv << ['motor_name', 'max_fuel', 'price', 'velocity', 'space', 'type']
					Motor.all.each do |motor|
						csv << [motor.name, motor.show_fuel_capacity, motor.price, motor.show_velocity, motor.space, motor.type]
					end					
				end
				print 'Success export Motor to CSV file.'
				gets.chomp
			end
		end
	end

	def vehicle_menu(person:, index_person:)
		option_vehicle = 0

		until (option_vehicle == 'exit') do
			system 'clear'
			puts '1. Buy Vehicle'
			puts '2. View All Vehicle'
			puts '3. Select Vehicle'
			puts '4. View Person Details'
			puts '5. Update Person Name'
			puts '6. Delete Person'
			puts '7. Create Vehicle'
			print 'Choose option number [type \'exit\' to stop] : '
			option_vehicle = gets.chomp

			case option_vehicle
			when '1'
				system 'clear'
				buy_vehicle(person: person)
			when '2'
				show_vehicle(vehicles: person.view_all_motor)
				gets.chomp
			when '3'
				vehicle_to_choose = ''
				vehicles = person.view_all_motor
				vehicle_count = vehicles.count
				until ((is_number?(vehicle_to_choose) && vehicle_to_choose.to_i <= vehicle_count && vehicle_to_choose.to_i > 0) || vehicle_to_choose == 'exit')
					show_vehicle(vehicles: person.view_all_motor)
					print "Choose vehicle by number [type 'exit' to back] : "
					vehicle_to_choose = gets.chomp
				end
				if (vehicle_to_choose != 'exit')
					index = vehicle_to_choose.to_i - 1
					vehicle = vehicles[index]
					
					print "You have chosen #{vehicle.name}."
					gets.chomp
					menu_operate_vehicle(vehicle: vehicle, index: index, person: person)
				end
			when '4'
				system 'clear'
				puts 'Person Details'
				puts "Name             : #{person.name}"
				puts "Current Capacity : #{person.current_capacity}"
				puts "Garage Capacity  : #{person.garage_capacity}"
				puts "Current Money    : #{person.money}"
				print 'Press enter to continue ...'
				gets.chomp
			when '5'
				puts "Current person name is #{person.name}"
				print 'Input new name : '
				person.name = gets.chomp
				print 'Success edit person name.'
				gets.chomp
			when '6'
				choose_delete_person = ''
				until(choose_delete_person == 'yes' || choose_delete_person == 'no')
					print "Are you sure to delete #{person.name}? [yes/no] : "
					choose_delete_person = gets.chomp
				end
				if(choose_delete_person == 'yes')
					Person.destroy(index_person)
					print 'Success delete person.'
					gets.chomp
					option_vehicle = 'exit'
				end
			when '7'
				system 'clear'
				puts '-- Create Vehicle --'
				result = create_vehicle
				if result[:type] == 'motor'
					new_vehicle = Motor.create(name: result[:name], max_fuel_capacity: result[:max_fuel_capacity], velocity: result[:velocity], space: result[:space].to_i, price: result[:price].to_i)
				else
					new_vehicle = Car.create(name: result[:name], max_fuel_capacity: result[:max_fuel_capacity], velocity: result[:velocity], space: result[:space].to_i, price: result[:price].to_i)
				end
				print 'Success create new vehicle.'
				person.add_motor(new_vehicle)
				gets.chomp
			end
		end
	end

	def menu_operate_vehicle(vehicle:, index:, person:)
		option_operate_vehicle = 0

		until option_operate_vehicle == 'exit' do	
			system 'clear'
			puts "-- Menu Vehicle --"
			puts ' 1. Display Details'
			puts ' 2. Refill Fuel'
			puts " 3. Run Vehicle"
			puts " 4. Change Vehicle Name"
			puts ' 5. Change Velocity'
			puts ' 6. Change Fuel Capacity'
			puts ' 7. Reset Status'
			puts ' 8. Sell Vehicle'
			puts ' 9. Press Horn'
			puts '10. Deliver Package'
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
					print "Vehicle run for #{result[0].to_digits} s and reached #{result[1].to_digits} M."
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
				option_operate_vehicle = sell_vehicle(person: person, index: index, vehicle_name: vehicle.name)
			when '9'
				vehicle.press_horn
			when '10'
				deliver_package(person: person, vehicle: vehicle)
			end
		end
	end

	def person_to_export
		persons = []
		Person.all.each do |person|
			motors = []
			person.view_all_motor.each do |motor|
				motors <<
				{
					'name': motor.name,
					'velocity': motor.show_velocity,
					'type': motor.type,
					'max_fuel': motor.show_fuel_capacity,
					'price': motor.price,
					'space': motor.space
				}
			end
			persons <<
			{
				'name': person.name,
				'money': person.money,
				'garage':
				{
					'capacity': person.garage_capacity,
					'motor': motors
				}
			}
		end
		persons
	end

	def show_person
		i = 0
		system 'clear'
		puts '-- List Person --'
		puts '| No |      Name      | Garage Capacity |    Money    |'
		Person.all.each do |person|
			printf "| %2s | %-14s | %15s | %11s |\n", (i+1), person.name, person.garage_capacity, person.money
			i += 1
		end
	end

	def buy_vehicle(person:)
		vehicle_to_buy = ''
		vehicles = Motor.all
		until ((is_number?(vehicle_to_buy) && vehicle_to_buy.to_i <= vehicles.count && vehicle_to_buy.to_i > 0) || vehicle_to_buy == 'exit')
			show_vehicle(vehicles: vehicles)
			puts "Current money : #{person.money}"
			print 'Choose vehicle by number [type \'exit\' to back] : '
			vehicle_to_buy = gets.chomp
		end
		if (vehicle_to_buy != 'exit')
			index = vehicle_to_buy.to_i - 1
			vehicle_price = vehicles[index].price
			if person.money >= vehicle_price
				buy_result = person.buy_motor(index: index, vehicle_price: vehicle_price)
				if buy_result == false
					print 'Cannot buy vehicle. Exceeded garage capacity.'
				else
					print 'Success buy new vehicle.'
				end
			else
				print 'Cannot buy vehicle. Insufficient money.'
			end
			gets.chomp
		end
	end

	def sell_vehicle(person:, index:, vehicle_name:)
		sell_confirmation = ''
		until(sell_confirmation == 'yes' || sell_confirmation == 'no')
			print "Are you sure to sell #{vehicle_name} for half the price? [yes/no] : "
			sell_confirmation = gets.chomp
		end
		if sell_confirmation == 'yes'
			person.remove_motor(index)
			print "Success sell #{vehicle_name} for half the price."
			gets.chomp
			'exit'
		end
	end

	def deliver_package(person:, vehicle:)
		if(vehicle.current_fuel > 0)
			delivery_time = rand(10..120)
			result = vehicle.run(BigDecimal.new(delivery_time))
			money_gained = result[0].round * 10
			person.increase_money(money_gained)
			print "Did delivery for #{result[0].to_digits} s and gained #{money_gained}."
			gets.chomp
		else
			print 'Vehicle does not have any fuel left, please refill the fuel.'
			gets.chomp
		end
	end
end
CliPerson.new