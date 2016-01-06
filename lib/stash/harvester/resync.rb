require 'uri'
require 'oai/client'

module Stash
  module Harvester
    # Harvesting support for [ResourceSync](http://www.openarchives.org/rs/1.0/resourcesync)
    module Resync
      Dir.glob(File.expand_path('../resync/*.rb', __FILE__), &method(:require))
    end
  end
end
