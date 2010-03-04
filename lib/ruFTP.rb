#!/usr/bin/env ruby
# 
#  ruFTP.rb
#  ruFtp - ruby ftp client - 0.2
#   
#  Created by Nss 
#             luca [at] tulug [dot] it.
# 
#  This library is distributed under the terms of the Ruby license. 
#  You can freely distribute/modify this library. 
# 

require "uri"
require "fileutils"
require "optparse"
require "set"
require "pp"
require "libruftp"

class Optparse

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    
    options=Myftp.available_options

    parser = OptionParser.new do |opts|
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
      
      opts.on('-D','--debug',"Enable debug") do
        options.debug_mode=true
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

    end

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
    ftp.exec(options) do |res|
      puts res
    end
  rescue Exception => detail
    $stderr.puts "Error: #{detail}"
  ensure
    ftp.close
  end  
end
