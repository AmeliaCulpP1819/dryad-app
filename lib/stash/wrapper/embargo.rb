require 'xml/mapping'
require 'xml/mapping_extensions'
require 'ruby-enum'

module Stash
  module Wrapper

    class EmbargoType
      include Ruby::Enum

      define :NONE, 'none'
      define :DOWNLOAD, 'download'
      define :DESCRIPTION, 'description'
    end

    # XML mapping for {EmbargoType}
    class EmbargoTypeNode < ::XML::MappingExtensions::EnumNodeBase
      ENUM_CLASS = EmbargoType
    end
    ::XML::Mapping.add_node_class EmbargoTypeNode

    # Dataset embargo.
    class Embargo
      include ::XML::Mapping
      embargo_type_node :type, 'type'
      text_node :period, 'period'
      date_node :start, 'start'
      date_node :end, 'end'
    end
  end
end
