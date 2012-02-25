
--[[
  日志模块，用于对四类信息分别进行记录
  V    Verbose  -- not support
  D    Debug  
  I    Info  
  W    Warn  
  E    Error  
  Example:
  local log = newlog("lfstest")
  local tag = "case1"
  log.e(tag, "cat not write")
  log.w(tag, "disk is full")
  log.i(tag, "disk's capacity is 64MB")
  log.d(tag, "val is "..val)
  log.close()
  如果想关掉其中某个输出，将其重置为一个空函数即可，如debug
  log.d = function (tag, msg) end
  通过log.dump(type)　可以把不同类型的日志数据分类提取到另一个文件
--]]
function newlog(logbasename)
	local createtime = os.date("%Y-%m-%d_%H-%M-%S", os.time())
	local logfname = logbasename.."_"..createtime..".log"
	--
	local f = io.open(logfname, "a+")
	f:write(logfname.." begin:\n")
	f:flush()
	--
	return {
		--记录错误信息　 
		e = function(tag, errmsg)
			local rt = os.date("%H:%M:%S", os.time())
			print("[err:"..tag..":"..rt.."]: "..errmsg)
			if nil == f then
				print("logfile: "..logfname.." is close")
				return false
			end
			f:write("[err:"..tag..":"..rt.."]: "..errmsg.."\n")
			f:flush()
		end, 
		
		--记录警告信息 
		w = function(tag, warmsg)
			local rt = os.date("%H:%M:%S", os.time())
			print("[warm:"..tag..":"..rt.."]: "..warmsg)
			if nil == f then
				print("logfile: "..logfname.." is close")
				return false
			end
			f:write("[warm:"..tag..":"..rt.."]: "..warmsg.."\n")
			f:flush()
		end, 
		
		--记录有用信息，如需要提取的信息  
		i = function(tag, infomsg)
			local rt = os.date("%H:%M:%S", os.time())
			print("[info:"..tag..":"..rt.."]: "..infomsg)
			if nil == f then
				print("logfile: "..logfname.." is close")
				return false
			end
			f:write("[info:"..tag..":"..rt.."]: "..infomsg.."\n")
			f:flush()
		end, 
		
		--输出debug信息　 
		d = function(tag, debugmsg)
			local rt = os.date("%H:%M:%S", os.time())
			print("[debug:"..tag..":"..rt.."]: "..debugmsg)
			if nil == f then
				print("logfile: "..logfname.." is close")
				return false
			end
			f:write("[debug:"..tag..":"..rt.."]: "..debugmsg.."\n")
			f:flush()
		end, 
		
		--关闭日志系统  
		close = function()
			f:close()
			f = nil
		end, 
		
		--在终端输出日志中关于某个标记的所有信息 
		printtag = function(tag)
			os.execute("cat "..logfname.." |grep "..tag)
		end, 
		
		--dumptype: "e", "w", "i", "d", 分类并提取指定类型的所有信息到新的文件中 
		dump = function(dumptype)
			local dt = {["e"]="err", ["w"]="warm", ["i"]="info", ["d"]="debug"}
			if nil == dt[dumptype] then
				print("type "..dumptype.." is not support")
				return false
			end
			
			local newlogfname = logfname.."_"..createtime.."_"..dumptype..".log"
			local f = io.popen("cat "..logfname)
			local nf = io.open(newlogfname, "w")
			for line in f:lines() do
				local t = string.find(line, dt[dumptype])
				if nil ~= t then
					print()
					nf:write(line.."\n")
				end
			end
			f:close()
			nf:close()
		end, 
		
		--返回日志的文件名, 用于获取当前的日志文件进行其它的扩展操作 
		name = logfname
	}
end
