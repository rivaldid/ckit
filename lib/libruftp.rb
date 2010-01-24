#!/usr/bin/env ruby
#
#
#  libruftp 0.1  
#
#  libruftp is written by Luca 'Nss' ded to CKit.
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


require "net/ftp"

=begin
@options={:host=>nil,
    :resume=>false,
    :password=>nil,
    :username=>nil,
    :passive=>false,
    :command=>nil,
    :filelist=>[]
  }
=end
class Myftp < Net::FTP

  FILECOMMAND=[:put,:get,:delete,:rmdir]
  COMMAND=[:ls]

  def self.available_options
    options={:host=>nil,
      :port=>21,
      :resume=>false,
      :password=>nil,
      :username=>nil,
      :passive=>false,
      :directory=>".",
      :command=>:ls,
      :uri=>nil,
      :filelist=>[]
    }
    return OpenStruct.new(options)
  end

  def self.supported_command
    return COMMAND.concat(FILECOMMAND)
  end

  def validate_options(options)
    if options.host.nil?
      raise ArgumentError,"Host Needed"
    end
    if FILECOMMAND.include?(options.command) and options.filelist.empty?
      raise ArgumentError,"You need to specify some file for this options"
    end
  end

  def initialize(*args)
    super(*args)
  end

  def exec(options)
    self.validate_options(options)
    
    self.connect(options.host, options.port)
    
    if options.username.nil?
      puts "user e n  il"
      self.login
    else
      self.login(options.username,options.password)
    end
    
    self.chdir(options.directory)

    if FILECOMMAND.include?(options.command)
      options.filelist.each { |f|
        self.method(options.command).call f
        yield "#{options.command} #{f}"
      }
    elsif COMMAND.include?(options.command)
        yield self.method(options.command).call
    end

    self.close
  end
end

if __FILE__==$0
  #files = ftp.list
  #puts files
  #ftp.close
end
