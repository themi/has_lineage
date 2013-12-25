require "has_lineage/class_methods"
require "has_lineage/instance_methods"

module HasLineage
  def self.included(base)
    base.class_eval do
      cattr_accessor :has_lineage_options
    end

    base.extend(ClassMethods)

    include InstanceMethods
  end
end