#!/usr/bin/env ruby
# 
#  libruftp.rb
#  ruFtp - ruby ftp client - 0.5
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
require "utils"

class Myftp < Net::FTP
  BLOCKSIZE=DEFAULT_BLOCKSIZE #default blocksize to send and receive
  RECVTIMEOUT=10 #wait RECVTIMEOUT seconds before hang up the connection
  #BLOCKSIZE=512
  PROGRCMD=[:put,:get]
  FILECOMMAND=[:delete,:rmdir,:mkdir].concat PROGRCMD #command who requires files
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
      :filelist=>[],
      :show_percent=>true,
      :show_time=>true
    }
    return OpenStruct.new(options)
  end

  def initialize(*args)
    super(*args)
  end

  #options is OpenStruct class
  def exec(options)
    @options=options
    validate_options(@options)
   
    connect(@options.host, @options.port)
    
    if @options.username.nil?
      login()
    else
      login(@options.username,@options.password)
    end
    
    chdir(@options.directory)
    
    if FILECOMMAND.include?(@options.command)
      @options.filelist.each do |file|
          
        method(@options.command).call file
          
        if PROGRCMD.include?(@options.command)
          yield " done\n"
        else
          yield "  -> #{file}... done\n"
        end
      end
    elsif COMMAND.include?(@options.command)
      yield self.method(@options.command).call
    end
  end
  
  private 
  
  def tvoidresp
    begin
      result = Timeout::timeout(RECVTIMEOUT) {
        voidresp
      }
    rescue Timeout::Error => detail
      $stderr.puts "Warning: #{detail}" if @options.debug_mode
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
  
  def print_info(file,info)
    print "\r  -> #{file}"
    print "\t #{info.percent_finisced}%" if @options.show_percent
    print "\t #{info.remaining_time}" if @options.show_time
    STDOUT.flush
  end
  
  def put(file, remotefile = File.basename(file), blocksize = BLOCKSIZE, &block)
    unless @binary
      self.puttextfile(file, remotefile, &block)
    else
      upload=TransfertStatus.new(File.size file)
      putbinaryfile(file, remotefile, blocksize) do |data|
        upload.updatestatus(data.size)
        print_info(File.basename(file),upload)
      end
    end
  end
  
  def get(remotefile, localfile = File.basename(remotefile), blocksize = BLOCKSIZE, &block)
    unless @binary
      gettextfile(remotefile, localfile, &block)
    else		
      download=TransfertStatus.new(size remotefile)
      getbinaryfile(remotefile, localfile, blocksize) do |data|
        download.updatestatus(data.size)
        print_info(File.basename(remotefile),download)
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
