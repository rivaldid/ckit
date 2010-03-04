#!/usr/bin/env ruby
#
#  utils.rb
#  ruFtp - ruby ftp client - 0.5
#
#  Created by Nss
#             luca [at] tulug [dot] it.
#
#  This library is distributed under the terms of the Ruby license.
#  You can freely distribute/modify this library.
#

class TransfertStatus
  attr_reader :percent_finisced

  def initialize(totalsize)
    @totalsize=totalsize.to_f;
    @starttime=Time.now.to_f;
    @precision=75 #how many step need for calculate remaing time
    @average_time=[]
    @average_time<<0
    @transferedsize=0;
    @percent_finisced=0;
  end



	def calc_average(time,transferedsize)
		if @precision>0
			@precision -=1
		else
			@average_time<<((@average_time.last*(@average_time.size-1))+(time/transferedsize))/(@average_time.size)
		end
	end

  def updatestatus(transferedsize)
    @transferedsize+=transferedsize;
    @percent_finisced=((@transferedsize/@totalsize)*100).truncate
    calc_average(Time.now.to_f-@starttime,@transferedsize)
  end

  def terminated?
    @transferedsize=@totalsize
  end

  def remaining_time
    if @precision<=0
      remaining_size=@totalsize-@transferedsize
      min=(((@average_time.last*remaining_size)/60).truncate).to_s.rjust(2,'0')
      sec=(((@average_time.last*remaining_size)%60).truncate).to_s.rjust(2,'0')
      "[#{min}:#{sec}]"
    else
      "[undef]"
    end
  end
end