#!/usr/bin/env ruby


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
  FILECOMMAND=[:delete,:rmdir].concat PROGRCMD
  COMMAND=[:ls]
  DEFAULT_BLOCKSIZE=1024
  
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

  def print_percent(file,percent) 
    print "\r=> #{file}: #{percent}% "
    STDOUT.flush
  end
  
  def put(localfile, remotefile = File.basename(localfile), blocksize = DEFAULT_BLOCKSIZE, &block)
        unless @binary
          self.puttextfile(localfile, remotefile, &block)
        else
          filesize=File.size localfile
          transferred = 0
          old_perc=-1
          putbinaryfile(localfile, remotefile, blocksize) { |data|
            transferred+=data.size
            percent_finished=(((transferred).to_f/filesize.to_f)*100).round
            if old_perc!=percent_finished
              print_percent(File.basename(localfile),percent_finished)
              old_perc=percent_finished
            end
          }
        end
  end
  
  def get(remotefile, localfile = File.basename(remotefile), blocksize = DEFAULT_BLOCKSIZE, &block)
       unless @binary
         self.gettextfile(remotefile, localfile, &block)
       else
         filesize=File.size localfile
         transferred = 0
         old_perc=-1
         puts "Starting get:"
         self.getbinaryfile(localfile, remotefile, blocksize) { |e|
           transferred+=sent.size
           percent_finished=(((transferred).to_f/filesize.to_f)*100).round
           if old_perc!=percent_finished
             print_percent(File.basename(localfile),percent_finished)
             old_perc=percent_finished
           end
         }  
         puts
       end
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
      puts "Starting #{options.command}: "
      options.filelist.each { |f|
          self.method(options.command).call f
          yield "==> #{f} finished"
      }
      puts "#{options.command} finished"
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
