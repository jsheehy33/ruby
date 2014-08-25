#!/usr/bin/ruby

require 'etc'

class Proccess
  ##	Needed for accessing class vars (Reading/Writing)
	attr_accessor :number, :name, :command, :uid, :user	

	##	Think created as private
 	## 	For read only/write only attr_reader/attr_writer

	def initialize (number)	
		@number=number
	end
  
	def path										##	Example of a "virtual instance variable"
		"/proc/#{@number}"				##	Think database derived value
	end	
	
	def to_s
		"#{@number} \t #{@name} \t #{@uid} \t #{@user}"
	end
end

def parse_uid (str)
  split = str.split(' ')
  ##  UID should be at first index
  return split[1]
end


##  Define procs array
procs=[]

##  For each file in /proc folder filter for pid's
Dir.foreach("/proc/") do |file|   
  if /\d+/.match("#{file}")   ##  Regexp for 1 or more digits
    proc = Proccess.new(file)
    procs.push proc
  end
end

p procs

procs.each do |prc|
  comm = File.open("#{prc.path}/comm", "r")
  comm.each_line do |line|      ##  File should only contain one line
    prc.name = line.chomp
  end
  comm.close

  cmdline = File.open("#{prc.path}/cmdline", "r")
  cmdline.each_line do |line|   ##  File should only contain one line
    prc.command = line.chomp
  end
  cmdline.close

  status = File.open("#{prc.path}/status", "r")
  status.each_line do |line|
    if /Uid.*/.match("#{line}")
      prc.uid=parse_uid(line)
      prc.user=Etc.getpwuid(prc.uid.to_i).name
    end
  end

  puts prc  
end

