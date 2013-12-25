require 'active_support/core_ext/array/conversions'

module HasLineage
  module LineageClassMethods

    def has_lineage options = {}

      raise "Options for has_lineage must be in a hash." unless options.is_a? Hash

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

    def roots
      where(has_lineage_options[:parent_key].to_sym, nil)
    end

  end
end