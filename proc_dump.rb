#!/usr/bin/ruby

class Proccess
	attr_reader :number, :name	##	Needed for accessing class vars (Reading/Writing)
															##	Think created as private
															## 	For read only/write only attr_reader/attr_writer

	def initialize (number, name)	
		@number=number
		@name=name
	end
	
	def path										##	Example of a "virtual instance variable"
		"/proc/#{@number}"				##	Think database derived value
	end	
	
	def to_s
		"proc #{@number} is #{@name}"
	end
end


p1 = Proccess.new(10,"newp")
puts p1
puts "#{p1.number}:#{p1.name}"
puts "#{p1.path}"
