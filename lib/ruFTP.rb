#!/usr/bin/env ruby
#
#
#  ruFTP 0.1
#
#  ruFTP is written by Luca 'Nss' ded to CKit.
#
#  Copyright (C) 2010   Dario 'Dax' Vilardi
#                       dax [at] deelab [dot] org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


require "uri"
require "fileutils"
require 'optparse'
require 'ostruct'
require 'pp'
require '~/.ckit/lib/libruftp.rb'

class Optparse

  
    
  
    

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    
    options=Myftp.available_options

    parser = OptionParser.new { |opts|
      opts.banner = "Usage: #{$0} -H HOST -c CMD [options] [files]"

      opts.on(:REQUIRED,'-H','--host HOST:[PORT]','Set the host') do |host|
        options.uri=host
        uri=URI.parse(host)
        if !uri.host.nil?
          options.host=uri.host
        else
          options.host=options.uri
        end
        if !uri.port.nil?
          options.port=uri.port
        end
      end

      opts.on('-u','--username USERNAME',"Set the username") do |user|
        options.username=user
      end

      opts.on('-p','--password PASSWORD','Set the password') do |password|
        options.password=password
      end

      opts.on('-d','--directory DIR','Set the remote directory') do |directory|
        options.directory=directory
      end

      opts.on('-R','--resume',"Enable resume") do
        options.resume=true
      end

      opts.on('-P','--passive',"Enable passive mode") do
        options.passive=true
      end
      command = Myftp.supported_command
      command_list = command.join(',')
      opts.on_tail('-c','--cmd CMD',command,"Set a Command #{command_list}") do |cmd|
        options.command=cmd.to_sym
      end
      
      opts.on_tail('-h','--help','Display this screen') do
        puts opts
        exit
      end

    }

    begin
      parser.parse!(args)
      if !args.empty?
        options.filelist=args
      end
    
    rescue OptionParser::ParseError => detail
      $stderr.puts "Error: #{detail}"
      puts parser
      exit
    end
    return options
  end
end

if __FILE__==$0
  options=Optparse.parse(ARGV)
  ftp=Myftp.new()
  begin
    ftp.exec(options) {|res|
      puts res
    }
  rescue Exception => detail
      $stderr.puts "Error: #{detail}"
      exit
  end  
end
