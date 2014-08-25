#!/usr/bin/ruby

require 'etc'       ##  Needed for getpwuid
require 'optparse'  ##  Needed for parsing CLAs

class MyProcess
  ##	Needed for accessing class vars (Reading/Writing)
	attr_accessor :number, :name, :command, :uid, :user	

	##	Think created as private
 	## 	For read only/write only attr_reader/attr_writer

	def initialize (number)	
		@number=number
	end
 
 	##	Example of a "virtual instance variable" 
  def path
		"/proc/#{@number}"				
	end	
	
	def to_s
		"#{@number} \t #{@uid} \t #{@user} \t #{@name}"
	end
end

def parse_uid (str)
  split = str.split(' ')
  ##  UID should be at first index
  return split[1]
end

def load_procs(procs)
  ##  For each file in /proc folder filter for pid's
  Dir.foreach("/proc/") do |file|   
    if /\d+/.match("#{file}")   ##  Regexp for 1 or more digits
      proc = MyProcess.new(file)
      procs.push proc
    end
  end

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
        begin 
        prc.user=Etc.getpwuid(prc.uid.to_i).name 
        rescue ArgumentError    ##  Some uids dont have pw entries
          prc.user=prc.uid
        end
      end
    end
  end
end

procs=[]
load_procs(procs)

options = {:uid=>nil,:user=>nil,:pid=>nil}
parser = OptionParser.new do|opts|
  
  opts.separator ""

  opts.banner="Usage: ./proc_dump.rb [options]"
  
  opts.on("-h", "--help", "Display this screen") do
     puts opts
     exit
  end

  opts.on("-a", "--all","Display all processes from all users") do
    procs.each do |p|
      puts p
    end
  end

  opts.on("-u", "--uid uid", "Display processes for specified uid") do |uid|
    options[:uid]=uid
    procs.each do|p|
      if p.uid==uid
        puts p
      end
    end
  end
  
  opts.on("-n", "--name uname", "Display processes for specified user") do |uname|
    options[:user]=uname
    procs.each do |p|
      if p.user==uname
        puts p
      end
    end
  end

  opts.on("-p", "--pid pid", "Display information about process with given pid") do |pid|
    options[:pid]=pid
    procs.each do |p|
      if p.number==pid
        puts p
      end
    end
  end 
end

parser.parse!
