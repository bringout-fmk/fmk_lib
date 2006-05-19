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
# 17.05.06, ver. 02.00
#
# Licensed under the same terms as Ruby

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
	  if  @prg_name[0] != '/' 
		@prg_name = (`pwd`).strip! + '/' + @prg_name.strip
		#puts "dodao tekuci dir  #{@prg_name}"
          end

	  @prg_name = @prg_name.sub(sc_dir, @dos_base_path)
	  @dir_name = File.dirname(@prg_name)

	  # unix -> dos
	  @prg_name = @prg_name.gsub(/\//, '\\\\')
	  @dir_name = @dir_name.gsub(/\//, '\\\\')

	  #if not ( @prg_name.include? @dos_base_path )
          #    @dos_cmd +=  @dos_base_path
          #end

        end

	def compile(prgname, sw="")
	  @prg_name = prgname
	  self.rewrite_path
	  @switches += " " + sw
	  @dos_cmd = "#{@dos_base_path}\\clp_bc\\run_clp.bat " 

     	  #svim skriptama moram proslijediti i bazni direktorij da bi dosemu
          #mogao da se pozicionira u taj direktorij
	  @dos_cmd += @dir_name 

     	  @dos_cmd += " "+ @prg_name
          @dos_cmd += " "+ @switches

	  @dosemu_launch_cmd = "dosemu -dumb -E \"#{@dos_cmd}\""

	  puts "Launch dosemu: #{@dosemu_launch_cmd}"
	  result = system(@dosemu_launch_cmd)
	  result = system("echo DOS Clipper 52e Compiler output")
	  result = system("----------------------------------------")
	  result = system("cat /tmp/clperr.txt")
	end

	def asm_compile(asmname, sw="")
	  @asm_name = asmname
	  self.rewrite_path
	  @switches += " " + sw
	  @dos_cmd = "#{@dos_base_path}\\clp_bc\\asm52.bat " 

     	  #svim skriptama moram proslijediti i bazni direktorij da bi dosemu
          #mogao da se pozicionira u taj direktorij
	  @dos_cmd += @dir_name 

     	  @dos_cmd += " "+ @asm_name
          @dos_cmd += " "+ @switches

	  @dosemu_launch_cmd = "dosemu -dumb -E \"#{@dos_cmd}\""

	  puts "Launch dosemu: #{@dosemu_launch_cmd}"
	  result = system(@dosemu_launch_cmd)
	  #result = system("echo Macro asembler output")
	  #result = system("----------------------------------------")
	  #result = system("cat /tmp/clperr.txt")
	end

	def c_compile(cname, sw="")
	  @c_name = cname
	  self.rewrite_path
	  @switches += " " + sw
	  @dos_cmd = "#{@dos_base_path}\\clp_bc\\c52.bat " 

     	  #svim skriptama moram proslijediti i bazni direktorij da bi dosemu
          #mogao da se pozicionira u taj direktorij
	  @dos_cmd += @dir_name 

     	  @dos_cmd += " "+ @c_name
          @dos_cmd += " "+ @switches

	  @dosemu_launch_cmd = "dosemu -dumb -E \"#{@dos_cmd}\""

	  puts "Launch dosemu: #{@dosemu_launch_cmd}"
	  result = system(@dosemu_launch_cmd)
	  #result = system("echo Macro asembler output")
	  #result = system("----------------------------------------")
	  #result = system("cat /tmp/clperr.txt")
	end

end

opts = OptionParser.new
builder = Builder.new
opts.on("-h", "--help") { RDoc::usage }
opts.on("-s", "--switches SW") { |sw| builder.switches += " " + sw }
opts.on("-c", "--compile ARGS") { |args| builder.compile(args) }
opts.on("-ac", "--asm-compile ARGS") { |args| builder.asm_compile(args) }
opts.on("-cc", "--c-compile ARGS") { |args| builder.c_compile(args) }

opts.parse(ARGV) 
