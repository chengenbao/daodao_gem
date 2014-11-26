$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

# rubygems
require 'rubygems'
require 'json'

module DaoDao
  autoload :VERSION,                   'daodao/version'
  autoload :City,                      'daodao/city'
  autoload :Hotel,                     'daodao/hotel'
  autoload :HttpRequester,             'daodao/http_requester'

  class << self
    def env
      ENV['DAODAO_ENV'] || 'development'
    end
  end
end
