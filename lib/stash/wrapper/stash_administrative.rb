require 'xml/mapping'
require_relative 'st_version'
require_relative 'st_license'
require_relative 'st_embargo'
require_relative 'st_inventory'

module Stash
  module Wrapper
    class StashAdministrative
      include ::XML::Mapping
      object_node :version, 'version', class: Version
      object_node :license, 'license', class: License
      object_node :embargo, 'embargo', class: Embargo
      object_node :inventory, 'inventory', class: Inventory

      def initialize(version:, license:, embargo:, inventory:)
        self.version = version
        self.license = license
        self.embargo = embargo
        self.inventory = inventory
      end
    end
  end
end
