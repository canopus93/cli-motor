class CliSportMotor
	load 'sport_motor.rb'

	def initialize
		menu
	end

	def is_number?(text)
		text.to_f.to_s == text.to_s || text.to_i.to_s == text.to_s
	end
		
	def show_motor
		i = 0
		system 'clear'
		puts '-- List Motor --'
		puts '| No |    Name    | Type | Fuel Capacity | Velocity |'
		SportMotor.all.each do |motor|
			printf "| %2s | %-10s | %4s | %13s | %8s |\n", (i+1), motor.name, motor.type, motor.max_fuel_capacity, motor.display_velocity_in_kmph(motor.velocity).round(3).to_digits
			i+= 1
		end
	end

	def menu_spedo_meter(motor:)
		option_spedo_meter = 0

		until (option_spedo_meter == 'exit') do
			system 'clear'
			puts 'Menu Spedo Meter'
			puts '1. Display Velocity in Km/h'
			puts '2. Display Velocity in M/h'
			puts '3. Display Velocity in M/s'
			puts '4. Display Distance Travelled in M'
			puts '5. Display Distance Travelled in Km'
			puts '6. Display Distance Travelled in Mile'
			puts '7. Display Time Travelled in s'
			puts '8. Display Time Travelled in h'
			print 'Choose option number [type \'exit\' to stop] : '
			option_spedo_meter = gets.chomp

			case option_spedo_meter
			when '1'
				print "Velocity : #{motor.display_velocity_in_kmph(motor.velocity).round(3).to_digits} Km/h"
			when '2'
				print "Velocity : #{motor.display_velocity_in_mph(motor.velocity).round(3).to_digits} M/h"
			when '3'
				print "Velocity : #{motor.velocity.round(3).to_digits} M/s"
			when '4'
				print "Distance Travelled : #{motor.distance_travelled.round(3).to_digits} M"
			when '5'
				print "Distance Travelled : #{motor.display_distance_in_km(motor.distance_travelled).round(3).to_digits} Km"
			when '6'
				print "Distance Travelled : #{motor.display_distance_in_mile(motor.distance_travelled).round(3).to_digits} Mile"
			when '7'
				print "Time Travelled : #{motor.time_travelled.round(3).to_digits} s"
			when '8'
				print "Time Travelled : #{motor.display_time_in_hour(motor.time_travelled).round(3).to_digits} h"
			end
			gets.chomp if option_spedo_meter != 'exit'
		end
	end

	def menu_motor(motor:, index:)
		option_motor = 0

		until (option_motor == 'exit') do	
			system 'clear'
			puts 'Menu motor'
			puts '1. Display Details'
			puts '2. Refill Fuel'
			puts '3. Change Gear'
			puts '4. Run Motor'
			puts '5. Press Horn'
			puts '6. Change Sport Motor Name'
			puts '7. Reset Status'
			puts '8. Destroy Motor'
			puts '9. Spedo Meter Engine'
			print 'Choose option number [type \'exit\' to stop] : '
			option_motor = gets.chomp

			case option_motor
			when '1'
				system 'clear'
				puts 'Motor Details :'
				puts "Name               : #{motor.name}"
				puts "Type               : #{motor.type} cc"
				puts "Current Gear       : #{motor.gear}"
				puts "Max Gear           : #{motor.max_gear}"
				puts "Current Fuel       : #{motor.current_fuel.round(3).to_digits} l"
				puts "Fuel Capacity      : #{motor.max_fuel_capacity} l"
				puts "Velocity           : #{motor.display_velocity_in_kmph(motor.velocity).round(3).to_digits} Km/h"
				puts "Time Travelled     : #{motor.display_time_in_hour(motor.time_travelled).round(3).to_digits} h"
				puts "Distance Travelled : #{motor.display_distance_in_km(motor.distance_travelled).round(3).to_digits} Km"
				print 'Press enter to continue ...'
				gets.chomp
			when '2'
				fuel_amount = ''
				until(is_number?(fuel_amount) || fuel_amount == 'exit')
					print 'Input amount of fuel to fill in litre [type \'exit\' to back] : '
					fuel_amount = gets.chomp
				end
				motor.fuel_refill(fuel_amount) if is_number?(fuel_amount)
			when '3'
				gear = ''
				until(is_number?(gear) || gear == 'exit')
					print 'Input gear number : '
					gear = gets.chomp
				end
				if(is_number?(gear))
					motor.change_gear(gear.to_i)
					gear = ''
				end
			when '4'
				if(motor.current_fuel > 0)
					run_time = ''
					until(is_number?(run_time) || run_time == 'exit')
						system 'clear'
						print 'Input amount of time to run in second [type \'exit\' to back] : '
						run_time = gets.chomp				
					end
					if is_number?(run_time)
						result = motor.run(BigDecimal.new(run_time))
						print "Sport Motor run for #{motor.display_time_in_hour(result[0]).round(3).to_digits} h and reached #{motor.display_distance_in_km(result[1]).round(3).to_digits} Km."
						gets.chomp
					end
				else
					print 'Motor does not have any fuel left, please refill the fuel.'
					gets.chomp
				end
			when '5'
				motor.press_horn
			when '6'
				puts "Current sport motor name is #{motor.name}"
				print 'Input new name : '
				motor.name = gets.chomp
				print 'Success edit motor name'
				gets.chomp
			when '7'
				motor.reset_motor
			when '8'
				choose_delete_motor = ''
				until(choose_delete_motor == 'yes' || choose_delete_motor == 'no')
					print "Are you sure to delete #{motor.name}? [yes/no] : "
					choose_delete_motor = gets.chomp
				end
				if(choose_delete_motor == 'yes')
					SportMotor.destroy(index)
					print 'Success delete motor.'
					gets.chomp
					option_motor = 'exit'
				end
			when '9'
				menu_spedo_meter(motor: motor)
			end
		end
	end

	def menu
		option = 0
		motor = ''
		choose_motor = ''

		until (option == 'exit') do
			system 'clear'
			puts 'Menu'
			puts '1. Create Sport Motor'
			puts '2. View All Sport Motor'
			puts '3. Select Sport Motor'
			print 'Choose option number [type \'exit\' to stop] : '
			option = gets.chomp

			case option
			when '1'
				system 'clear'
				puts '-- Create Sport Motor --'
				print 'Input Sport Motor Name : '
				name = gets.chomp
				type = ''
				until (is_number?(type) && (type == '110' || type == '120' || type == '250' || type == '300'))
					print 'Input Type [110/120/250/300] in cc : '
					type = gets.chomp
				end
				SportMotor.create(name: name, type: type.to_i)
				print 'Success create new sport motor.'
				gets.chomp
			when '2'
				show_motor
				gets.chomp
			when '3'
				choose_motor = ''
				until ((is_number?(choose_motor) && choose_motor.to_i <= SportMotor.all.count && choose_motor.to_i > 0) || choose_motor == 'exit')
					show_motor
					print 'Choose motor by number [type \'exit\' to back] : '
					choose_motor = gets.chomp
				end
				if (choose_motor != 'exit')
					index = choose_motor.to_i - 1
					motor = SportMotor.all[index]
					print "You have chosen #{motor.name}."
					gets.chomp
					menu_motor(motor: motor, index: index)
					motor = ''
					choose_motor = ''
				end
			end
		end
	end
end