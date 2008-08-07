module DSMemcached
  module ClassMethods
    def caches(method, options = {})
      options = {
        :expires_in=>nil
      }.merge(options)
      # :with code lifted from err's cache_fu
      if options.keys.include?(:with) 
        with = options.delete(:with)
        memcache.fetch(
          "#{self}:#{method}:#{with}".gsub(" ","_"), 
          :expires_in => options[:expires_in]
        ) { send(method, with) }
      elsif withs = options.delete(:withs)
        memcache.fetch(
          "#{self}:#{method}:#{withs}".gsub(" ","_"), 
          :expires_in => 10.seconds
        ) { 
          send(method, *withs) 
        }
      else
        memcache.fetch(
          "#{self}:#{method}", 
          :expires_in => options[:expires_in]
        ) { 
          send(method) 
        }
      end
    end
    def memcache
      ActiveSupport::Cache.lookup_store(:mem_cache_store)
    end
  end
end
ActiveRecord::Base.extend(Memcacher::ClassMethods)