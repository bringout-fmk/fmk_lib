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
# 17.05.06-27.05.06, ver. 02.08
#
# Licensed under the same terms as Ruby

VER = '02.08'

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
	
	attr_reader  :prg_name, :dir_name, :switches, :output_exe_name, :debug
	attr_writer  :switches, :output_exe_name, :debug

	def say_time
	  puts Time.now.strftime("%d.%m.%Y %H:%m")
        end

	def initialize
	  @prg_name=nil
	  @dos_base_path="c:\\dev\\"
	  @dos_cmd=nil
	  @switches=""
          @output_exe_name="e.exe"
	  @debug="0"
	end

	def rewrite_path(unix_name)
	  sc_dir = ENV['SC_BUILD_HOME_DIR'] + '/'
          # test.prg => /home/hernad/sc/sclib/db/1g/test.prg
	  if  unix_name[0].chr != '/' 
		unix_name = (`pwd`).strip! + '/' + unix_name.strip
          end

	  unix_name = unix_name.sub(sc_dir, @dos_base_path)
	  
	  return unix_name
        end
         
	def unix_to_dos(path)
		path.gsub(/\//, '\\\\')
        end

	def stop(xvar="")
                puts xvar
		STDOUT.puts "press any key to continue ..."
		STDIN.readchar     
        end

	def compile(prgname, sw="", compile_batch_name="run_clp.bat", sw_first=FALSE)
	  @prg_name = prgname
	  @prg_name = rewrite_path(@prg_name)
	  @switches += " " + sw
	  @dos_cmd = "#{@dos_base_path}clp_bc\\#{compile_batch_name} " 

	  # + c:\dev\sclib\print\1g
	  @dos_cmd += unix_to_dos(File.dirname(@prg_name))
	  # + ptxt.prg
	  if sw_first
            @dos_cmd += " "+ @switches
          end
	      
     	  @dos_cmd += " "+ File.basename(@prg_name)

          if not sw_first
	    # /DC52
            @dos_cmd += " "+ @switches
          end

	  STDERR.puts "clipper compiler DOS ver 5.2e, clipper.rb ver #{VER}"
	  STDERR.puts "cmd : #{@dos_cmd}"
	  @dosemu_launch_cmd = "dosemu -dumb -quiet -E \"#{@dos_cmd}\""

	  puts "Launch dosemu: #{@dosemu_launch_cmd} , clipper.rb ver. #{VER}"

	  result = system(@dosemu_launch_cmd)
	end
	

        def lib(libcmd, sw="", compile_batch_name="lib.bat")
	  @prg_name = libcmd
	  @prg_name = rewrite_path(@prg_name)
	  @switches += " " + sw

          #libname.lib +obj1 +obj2 +obj3 ,,
	  lib_cmds = File.basename(@prg_name) 
	  
	  a_cmds = lib_cmds.split(' ')
	  lib_name = a_cmds[0]
          STDERR.puts "creating lib:" + lib_name
	  # create a batch file c:\dev\clp_bc\tmp\lib.bat
          f_bat_name = 'libtmp.bat'
          f_bat_full_name = ENV['SC_BUILD_HOME_DIR'] + '/clp_bc/tmp/' + f_bat_name
	  f_bat = File.open( f_bat_full_name, 'w')
          f_bat.puts "@echo off"
          f_bat.puts "@echo --- clipper.rb ver. #{VER} ---"
	  for i in 1..(a_cmds.size-1)
	     @dos_cmd = "call #{@dos_base_path}clp_bc\\#{compile_batch_name} " 
	     # + c:\dev\sclib\print\1g
	     @dos_cmd += unix_to_dos(File.dirname(@prg_name))
	     # + libname.lib  +obj1
     	     @dos_cmd += " "+lib_name+" "+a_cmds[i] 
             @dos_cmd += " "+ @switches
             f_bat.puts @dos_cmd
          end
	  f_bat.puts "exitemu"
	  f_bat.close
	  @dos_cmd = "#{@dos_base_path}clp_bc\\tmp\\#{f_bat_name} " 
	  @dosemu_launch_cmd = "dosemu -dumb -quiet -E \"#{@dos_cmd}\""
	  puts "Launch dosemu: #{@dosemu_launch_cmd} , clipper.rb ver. #{VER}"
	  result = system(@dosemu_launch_cmd)

	end

        def compile_all(compile_cmd, sw="", compile_batch_name="run_clp.bat /noexit ")
	  @prg_name = compile_cmd
	  @switches += " " + sw

	  a_cmds = @prg_name.split(' ')

	  
	  # create a batch file c:\dev\clp_bc\tmp\lib.bat
          f_bat_name = 'clptmp.bat'
          f_bat_full_name = ENV['SC_BUILD_HOME_DIR'] + '/clp_bc/tmp/' + f_bat_name
	  f_bat = File.open( f_bat_full_name, 'w')
          f_bat.puts "@echo off"
          f_bat.puts "@echo --- clipper.rb ver. #{VER} ---"
	  for i in 1..(a_cmds.size-1)
	     @dos_cmd = "call #{@dos_base_path}clp_bc\\#{compile_batch_name} " 

	     # + c:\dev\sclib\print\1g
             tmp = unix_to_dos(a_cmds[0])
	     @dos_cmd += tmp
	     # + print.prg
     	     @dos_cmd += " " + a_cmds[i]
             @dos_cmd += " " + @switches
             f_bat.puts @dos_cmd
          end

	  f_bat.puts "exitemu"
	  f_bat.close
	  @dos_cmd = "#{@dos_base_path}clp_bc\\tmp\\#{f_bat_name} " 
	  @dosemu_launch_cmd = "dosemu -dumb -quiet -E \"#{@dos_cmd}\""
	  puts "Launch dosemu: #{@dosemu_launch_cmd} , clipper.rb ver. #{VER}"
	  result = system(@dosemu_launch_cmd)

	end

        def blink(base_dir)

	  base_dir = rewrite_path(base_dir)

	  STDERR.puts "creating exe - blinking ..."
          f_lnk_name = '_bl_.lnk'
          f_lnk_full_name = ENV['SC_BUILD_HOME_DIR'] + '/clp_bc/tmp/' + f_lnk_name
	  f_lnk = File.open( f_lnk_full_name, "a+")

          f_lnk.puts "#---- #{Time.now} ----"
          f_lnk.puts "blinker message noblink"
#         f_lnk.puts "verbose"
	  f_lnk.puts "blinker exe compress"
 	  f_lnk.puts "BLINKER EXECUTABLE EXTENDED"
	  f_lnk.puts "blinker exe CLIPPER F:100"
	  #f_lnk.puts "BLINKER EXECUTABLE IPX 96,64"

#	  f_lnk.puts "BLINKER HOST DPMI  OFF"
	  f_lnk.puts "BLINKER HOST MESSAGE ON"
#	  f_lnk.puts "BLINKER HOST QDPMI OFF"
#	  f_lnk.puts "BLINKER HOST VCPI OFF"
#	  f_lnk.puts "BLINKER HOST XMS OFF"
#	  f_lnk.puts "BLINKER LINK EMS OFF"

	  f_lnk.puts "stack 8192"

          # standard clipper libs
	  #f_lnk.puts "lib #{@dos_base_path}\\clp_bc\\clipper\\lib\\CLIPPER.LIB"
	  #f_lnk.puts "lib #{@dos_base_path}\\clp_bc\\clipper\\lib\\EXTEND.LIB"
	  #f_lnk.puts "lib #{@dos_base_path}\\clp_bc\\clipper\\lib\\DBFNTX.LIB"

	  f_lnk.puts "search #{@dos_base_path}clp_bc\\blinker\\lib\\blxclp52.lib"

	  #f_lnk.puts "file #{@dos_base_path}clp_bc\\comix\\obj\\cmxfox52.obj"
	  f_lnk.puts "file #{@dos_base_path}clp_bc\\comix\\obj\\cm52.obj"
	  f_lnk.puts "file #{@dos_base_path}clp_bc\\comix\\obj\\cmx52.obj"
	  f_lnk.puts "file #{@dos_base_path}clp_bc\\ct\\obj\\ctusp.obj"

	  f_lnk.puts "file #{@dos_base_path}clp_bc\\CSY\\LIB\\CSYINSP.LIB"

	  #cm*.lib mora ici prva, pa onda cmx*.lib
	  f_lnk.puts "lib #{@dos_base_path}clp_bc\\comix\\lib\\cm52.lib"
	  f_lnk.puts "lib #{@dos_base_path}clp_bc\\comix\\lib\\cmx52.lib"

	  f_lnk.puts "lib #{@dos_base_path}clp_bc\\ct\\lib\\ctp52.lib"
	  f_lnk.puts "lib #{@dos_base_path}clp_bc\\daveh\\lib\\oslib.lib"
	  f_lnk.puts "lib #{@dos_base_path}clp_bc\\CSY\\LIB\\CLASSY.LIB"


          # clp_bc/vendor
	  f_lnk.puts "lib CLIPMOUS.LIB"



	  if self.debug == "1"          
		f_lnk.puts "file #{@dos_base_path}clp_bc\\clipper\\lib\\cld.lib"
          end

	  f_lnk.puts "output #{self.output_exe_name}"
	  #f_lnk.puts "fi  #{mainobj}"
	  f_lnk.puts ""

	  f_lnk.close

	  @dos_cmd = "#{@dos_base_path}clp_bc\\blink.bat #{unix_to_dos(base_dir)} " 
	  @dosemu_launch_cmd = "dosemu -dumb -quiet -E \"#{@dos_cmd}\""
	  puts "Launch dosemu: #{@dosemu_launch_cmd} , clipper.rb ver. #{VER}"
	  result = system(@dosemu_launch_cmd)

	end

end

opts = OptionParser.new
builder = Builder.new

opts.on("-h", "--help") { RDoc::usage }
opts.on("-s", "--switches SW") { |sw| builder.switches += " " + sw }
opts.on("-c", "--compile ARGS") { |args| builder.compile(args) }
opts.on("-ca", "--compile-all ARGS") { |args| builder.compile_all(args) }

opts.on("-ac", "--asm-compile ARGS") { |args| builder.compile(args, "", "asm52.bat") }
opts.on("-cc", "--c-compile ARGS") { |args| builder.compile(args, "", "c52.bat", TRUE) }

opts.on("-lib", "--make-lib ARGS") { |args| builder.lib(args, "", "lib.bat") }
opts.on("-d", "--debug ARG") { |arg| builder.debug = arg}
opts.on("-out", "--output-exe ARGS") { |arg| builder.output_exe_name = arg }
opts.on("-b", "--blink BASEDIR") { |basedir| builder.blink(basedir) }

opts.parse(ARGV) 
