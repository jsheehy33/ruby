#!/usr/bin/ruby

class Proccess
  ##	Needed for accessing class vars (Reading/Writing)
	attr_accessor :number, :name, :command	

	##	Think created as private
 	## 	For read only/write only attr_reader/attr_writer

	def initialize (number)	
		@number=number
	end
  
	def path										##	Example of a "virtual instance variable"
		"/proc/#{@number}"				##	Think database derived value
	end	
	
	def to_s
		"#{@number} \t #{@name} \t"
	end
end

## Define procs array
procs=[]

## For each file in /proc folder filter for pid's
Dir.foreach("/proc/") do |file|   
  if /\d+/.match("#{file}")   ##  Regexp for 1 or more digits
    proc = Proccess.new(file)
    procs.push proc
  end
end

p procs

procs.each do |p|
  comm = File.open("#{p.path}/comm", "r")
  comm.each_line do |line|      ##  File should only contain one line
    p.name = line
  end
  comm.close

  cmdline = File.open("#{p.path}/cmdline", "r")
  cmdline.each_line do |line|   ##  File should only contain one line
    p.command = line
  end
  cmdline.close
  puts p
end


