#!/usr/bin/ruby
# == Synopsis
#    Faxiraj sve dokumente iz direktorija komandom send_fax.sh
#
# == Usage
#
#      faxiraj_sve_dokumente.rb.rb [-h | --help] [-d --directory directory ]
#      
# == Example
#      ~/bin/faxiraj --directory ~/cup-ps 
#
# == Author
# Ernad Husremovic, Sigma-com software Zenica
#
# == Copyright
#
#
# Copyright (c) 2006 Sigma-com, 
# 29.05.06-29.05.06, ver. 00.15
#
# Licensed under the same terms as Ruby

require 'optparse'
require 'rdoc/usage'

VER="00.16"


class SendFax

	attr_reader :directory
	attr_writer :directory

	def initialize
		 @directory = ""
	end

	def ps_files
		Dir::chdir(@directory)
		Dir::glob("*.ps")
	end
	

	def extract_fax_num(filename)
		# evo kako izgleda ime fajla
		#                1              2             3                        4
		# FAKT_DOK_10-10-00246-1PF01_29.05.06_PLANIKA-FLEX-d.o.o-SARAJEVO_FAX-033768915.ps
		re = Regexp.new('.+_.+_.+_.+_.+_FAX\-(\d+).ps')
		#re = Regexp.new('FAKT_DOK_.*_FAX\-(\d+).ps')
		md = filename.match(re)
		if md != nil
			return md[1]
		end
		return "NOFAX"
	end

	def send_fax(file, fax_num)
		cmd = "send_fax.sh #{fax_num} '#{@directory+'/'+file}'"
		return system(cmd)
	end

	def send
		puts "sending faxes ..."
		dirs = ps_files
		dirs.each do | file |
  		  fax_num = extract_fax_num(file)
		  if fax_num != "NOFAX"
		  	result = send_fax(file, fax_num)
			if result
				cmd = "mv #{directory+'/'+file} #{directory}/sent"
				system(cmd)
			else
				puts "result = #{result} , move nije napravljen "

			end

		  else
			puts "ERROR: Dokument #{file} nema ispravan broj fax-a !!!"
		  end
		end
	end

end

opts = OptionParser.new
faxer = SendFax.new

opts.on("-h", "--help") { RDoc::usage }
opts.on("-d", "--directory DIR") { |dir| faxer.directory = dir }

opts.parse(ARGV)


faxer.send
