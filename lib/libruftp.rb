#!/usr/bin/env ruby
# 
#  libruftp.rb
#  ruFtp - ruby ftp client - 0.2
#   
#  Created by Nss 
#             luca [at] tulug [dot] it.
# 
#  This library is distributed under the terms of the Ruby license. 
#  You can freely distribute/modify this library. 
# 


require "net/ftp"
require "ostruct"

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
  PROGRCMD=[:put,:get]
  FILECOMMAND=[:delete,:rmdir,:mkdir].concat PROGRCMD
  COMMAND=[:ls]
  DEFAULT_BLOCKSIZE=1024
  
  def self.supported_command
    return COMMAND.concat(FILECOMMAND)
  end
         
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

  def print_string(string)
    print string
    STDOUT.flush
  end
  
  def print_percent(file,percent) 
    print "\r  -> #{file}... #{percent}%"
    STDOUT.flush
  end
  
  def put(file, remotefile = File.basename(file), blocksize = DEFAULT_BLOCKSIZE, &block)
        unless @binary
          self.puttextfile(file, remotefile, &block)
        else
          filesize=File.size file
          transferred = 0
          old_perc=-1
          putbinaryfile(file, remotefile, blocksize) { |data|
            transferred+=data.size
            percent_finished=(((transferred).to_f/filesize.to_f)*100).round
            if old_perc!=percent_finished
              print_percent(File.basename(file),percent_finished)
              old_perc=percent_finished
            end
          }
        end
  end
  
  def get(remotefile, localfile = File.basename(remotefile), blocksize = DEFAULT_BLOCKSIZE, &block)
       unless @binary
         gettextfile(remotefile, localfile, &block)
       else
         filesize=size remotefile
         transferred = 0
         old_perc=-1
         getbinaryfile(remotefile, localfile, blocksize) { |data|
           transferred+=data.size
           percent_finished=(((transferred).to_f/filesize.to_f)*100).round
           if old_perc!=percent_finished
             print_percent(File.basename(File.basename(remotefile)),percent_finished)
             old_perc=percent_finished
           end
         }  
       end
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
    validate_options(options)
    connect(options.host, options.port)
    
    if options.username.nil?
      login()
    else
      login(options.username,options.password)
    end
    
    chdir(options.directory)

    if FILECOMMAND.include?(options.command)
     
      options.filelist.each { |file|
          method(options.command).call file
          if PROGRCMD.include?(options.command)
            yield " done"
          else
            yield "  -> #{file}... done"
          end
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
