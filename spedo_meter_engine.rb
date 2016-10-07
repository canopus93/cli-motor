module SpedoMeterEngine
	def display_velocity_in_kmph(velocity)
		velocity * 3.6
	end
	
	def display_velocity_in_mph(velocity)
		velocity * 3600
	end

	def display_distance_in_km(distance)
		distance / 1000
	end

	def display_distance_in_mile(distance)
		distance * 0.000621371
	end

	def display_time_in_hour(time)
		time * 0.000277778
	end
end