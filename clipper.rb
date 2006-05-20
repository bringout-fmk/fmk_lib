#!/usr/bin/ruby
# == Synopsis
#    This is program for compilig dos/clipper programs
#    under linux environment
#
# == Usage
#
#      clipper.rb [-h | --help] [ -s | --switches  switches ]  [ -c | --compile  prg_file ]
#      
#      prg_file - program file to compile
#      switches - compiler switches
#
#      NOTE: "switches" arguments have to precede "compile" argument 
#
# == Example
#      ~/sc/sclib/clipper.rb --switches /b /d --compile test.prg
#
# == Author
# Ernad Husremovic, Sigma-com software Zenica
#
# == Copyright
#
#
# Copyright (c) 2006 Sigma-com, 
# 17.05.06-19.05.06, ver. 02.01
#
# Licensed under the same terms as Ruby

VER = '02.02'

require 'optparse'
require 'rdoc/usage'

ERRORS= ["No code generated",
         "include error", 
         "Statement not recognized",
         "Syntax error",
         "syntax error", 
         "t open",
         "Error"]

class Builder
	
	attr_reader  :prg_name, :dir_name, :switches
	attr_writer  :switches 

	def say_time
	  puts Time.now.strftime("%d.%m.%Y %H:%m")
        end

	def initialize
	  @prg_name=nil
	  @dos_base_path="c:\\dev\\"
	  @dos_cmd=nil
	  @switches=""
	end

	def rewrite_path
	  sc_dir = ENV['SC_BUILD_HOME_DIR'] + '/'
          # test.prg => /home/hernad/sc/sclib/db/1g/test.prg
	  if  @prg_name[0].chr != '/' 
		@prg_name = (`pwd`).strip! + '/' + @prg_name.strip
		#puts "dodao tekuci dir  #{@prg_name}"
          end

	  @prg_name = @prg_name.sub(sc_dir, @dos_base_path)
	  


        end
         
	def unix_to_dos(path)
		path.gsub(/\//, '\\\\')
        end

	def stop(xvar="")
                puts xvar
		STDOUT.puts "press any key to continue ..."
		STDIN.readchar     
        end

	def compile(prgname, sw="", compile_batch_name="run_clp.bat")
	  @prg_name = prgname
	  self.rewrite_path
	  @switches += " " + sw
	  @dos_cmd = "#{@dos_base_path}clp_bc\\#{compile_batch_name} " 

	  # + c:\dev\sclib\print\1g
	  @dos_cmd += unix_to_dos(File.dirname(@prg_name))
	  # + ptxt.prg
     	  @dos_cmd += " "+ File.basename(@prg_name)
	  # /DC52
          @dos_cmd += " "+ @switches

	  @dosemu_launch_cmd = "dosemu -dumb -E \"#{@dos_cmd}\""

	  puts "Launch dosemu: #{@dosemu_launch_cmd} , clipper.rb ver. #{VER}"
	  result = system(@dosemu_launch_cmd)
	end

end

opts = OptionParser.new
builder = Builder.new
opts.on("-h", "--help") { RDoc::usage }
opts.on("-s", "--switches SW") { |sw| builder.switches += " " + sw }
opts.on("-c", "--compile ARGS") { |args| builder.compile(args) }
opts.on("-ac", "--asm-compile ARGS") { |args| builder.compile(args, "", "asm52.bat") }
opts.on("-cc", "--c-compile ARGS") { |args| builder.compile(args, "", "c52.bat") }
opts.on("-lib", "--make-lib") { |args| builder.compile(args, "", "lib.bat") }

opts.parse(ARGV) 
