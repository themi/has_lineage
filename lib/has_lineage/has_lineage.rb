require 'active_support/concern'

module HasLineage
  def self.included(base)
    base.class_eval do
      cattr_accessor :has_lineage_options
    end

    base.extend(ClassMethods)

    include InstanceMethods
  end

  module ClassMethods
    def has_lineage options = {}

      options.assert_valid_keys(:parent_key, :lineage_column, :leaf_width, :delimiter, :branch_key, :order, :counter_cache)

      self.has_lineage_options = { 
              :parent_key => "parent_id", 
              :lineage_column => "lineage", 
              :leaf_width => 4, 
              :delimiter => '/',
              :branch_key => nil, 
              :order => nil, 
              :counter_cache => false }.update(options)

    end
  end

  module InstanceMethods
    def nothing
      'nothing'
    end
  end

end