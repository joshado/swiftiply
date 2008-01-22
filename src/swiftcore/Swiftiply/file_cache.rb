begin
	load_attempted ||= false
	require 'swiftcore/Swiftiply/cache_base'
rescue LoadError => e
	if !load_attempted
		load_attempted = true
		begin
			require 'rubygems'
		rescue LoadError
			raise e
		end
		retry
	end
	raise e
end

module Swiftcore
	module Swiftiply
		class FileCache < CacheBase
			
			def add(path,data,etag,mtime,header)
				unless self[path]
					add_to_verification_queue(path)
					ProxyBag.logger.log('info',"Adding file #{path} to file cache") if ProxyBag.log_level > 2
				end
				self[path] = [data,etag,mtime,header]
			end
			
			def verify(path)
				if f = self[path] and File.exist?(path)
					mt = File.mtime(path)
					if mt == f[2]
						true
					else
						false
					end
				else
					false
				end
			end
		end
	end
end
