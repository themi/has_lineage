require "has_lineage/exception"
require "has_lineage/class_methods"
require "has_lineage/instance_methods"
require "active_support/concern"
require "active_support/core_ext/class/attribute_accessors"

module HasLineage
  extend ActiveSupport::Concern

  included do
    cattr_accessor :has_lineage_options
  end

  module ClassMethods
    include LineageClassMethods
  end

  include LineageInstanceMethods
end