#!/usr/bin/env ruby
# 
#  libruftp.rb
#  ruFtp - ruby ftp client - 0.31
#   
#  Created by Nss 
#             luca [at] tulug [dot] it.
# 
#  This library is distributed under the terms of the Ruby license. 
#  You can freely distribute/modify this library. 
# 


require "net/ftp"
require "ostruct"
require "pp"
require "timeout"

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
  BLOCKSIZE=DEFAULT_BLOCKSIZE
  RECVTIMEOUT=10
  #BLOCKSIZE=32
  PROGRCMD=[:put,:get]
  FILECOMMAND=[:delete,:rmdir,:mkdir].concat PROGRCMD
  COMMAND=[:ls]
  
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
      :debug_mode=>false,
      :filelist=>[]
    }
    return OpenStruct.new(options)
  end

  def initialize(*args)
    super(*args)
  end

  def exec(options)
    validate_options(options)
    
    self.passive=options.passive
    self.debug_mode=options.debug_mode
    self.resume=options.resume
    @options=options
    connect(options.host, options.port)
    
    if options.username.nil?
      login()
    else
      login(options.username,options.password)
    end
    
    chdir(options.directory)
    
    if FILECOMMAND.include?(options.command)
      options.filelist.each do |file|
          
          method(options.command).call file
          
          if PROGRCMD.include?(options.command)
            yield " done\n"
          else
            yield "  -> #{file}... done\n"
          end
      end
    elsif COMMAND.include?(options.command)
      yield self.method(options.command).call
    end
  end
  
  private 
  
  def tvoidresp
      begin  
        result = Timeout::timeout(RECVTIMEOUT) {
          voidresp
        }
      rescue Timeout::Error => detail
            $stderr.puts "Warning: #{detail}" if @debug_mode
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

  def print_string(string)
    print string
    STDOUT.flush
  end
  
  def print_percent(file,percent) 
    print "\r  -> #{file}... #{percent}%"
    STDOUT.flush
  end
  
  def put(file, remotefile = File.basename(file), blocksize = BLOCKSIZE, &block)
          unless @binary
            self.puttextfile(file, remotefile, &block)
          else
            filesize=File.size file
            transferred = 0
            old_perc=-1
            
                putbinaryfile(file, remotefile, blocksize) do |data|
                    transferred+=data.size
                    percent_finished=(((transferred).to_f/filesize.to_f)*100).truncate
                    if old_perc!=percent_finished
                      print_percent(File.basename(file),percent_finished)
                      old_perc=percent_finished
                    end  
                end
           
          end
  end
  
  def get(remotefile, localfile = File.basename(remotefile), blocksize = BLOCKSIZE, &block)
    unless @binary
      gettextfile(remotefile, localfile, &block)
    else
      filesize=size remotefile
      transferred = 0
      old_perc=-1
      getbinaryfile(remotefile, localfile, blocksize) do |data|
          transferred+=data.size
          percent_finished=(((transferred).to_f/filesize.to_f)*100).truncate
          if old_perc!=percent_finished
            print_percent(File.basename(File.basename(remotefile)),percent_finished)
            old_perc=percent_finished
          end
      end
    end
  end
  
  def storbinary(cmd, file, blocksize, rest_offset = nil, &block) # :yield: data
    if rest_offset
      file.seek(rest_offset, IO::SEEK_SET)
    end
    synchronize do
      voidcmd("TYPE I")
      conn = transfercmd(cmd, rest_offset)
      loop do
        buf = file.read(blocksize)
        break if buf == nil
        conn.write(buf)
        yield(buf) if block
      end
      conn.close
      tvoidresp
    end
  end
  
  # File net/ftp.rb, line 466
      def storlines(cmd, file, &block) # :yield: line
        synchronize do
          voidcmd("TYPE A")
          conn = transfercmd(cmd)
          loop do
            buf = file.gets
            break if buf == nil
            if buf[-2, 2] != CRLF
              buf = buf.chomp + CRLF
            end
            conn.write(buf)
            yield(buf) if block
          end
          conn.close
          tvoidresp
        end
      end
  
  
  
end

if __FILE__==$0
  #files = ftp.list
  #  puts files
  #ftp.close
end
