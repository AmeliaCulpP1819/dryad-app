module Stash
  # Code relating to the {https://dash.cdlib.org/stash_wrapper/ Stash wrapper format}
  module Wrapper
    # The name of this gem
    NAME = 'stash-wrapper'

    # The version of this gem
    VERSION = '0.0.1'

    # The copyright notice for this gem
    COPYRIGHT = 'Copyright (c) 2015 The Regents of the University of California'

    Dir.glob(File.expand_path('../wrapper/*.rb', __FILE__), &method(:require))
  end
end
