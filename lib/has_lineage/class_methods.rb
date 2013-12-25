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

      belongs_to :lineage_parent, :class_name => name, :foreign_key => has_lineage_options[:parent_key], :counter_cache => has_lineage_options[:counter_cache]
      has_many :lineage_children, -> { order(%Q[#{has_lineage_options[:order]}]) }, :class_name => name, :foreign_key => has_lineage_options[:parent_key], :dependent => :destroy
    end

    def roots
      where("#{has_lineage_options[:parent_key]} IS NULL")
    end

    def root_for(value)
      return nil unless value.present?
      where("#{has_lineage_options[:lineage_column]} = ?", value.split("#{has_lineage_options[:delimiter]}")[0])
    end

    def descendants_of(value)
      if value.present?
        where("#{has_lineage_options[:lineage_column]} LIKE ?", value + "%")
      else
        all
      end
    end

    def ancestors_for(value)
      return [] unless value.present?
      where("#{has_lineage_options[:lineage_column]} IN (?)", value.split("#{has_lineage_options[:delimiter]}"))
    end

    def lineage_order(sort_lineage = true)
      if sort_lineage
        order(%Q{#{has_lineage_options[:lineage_column]}})
      else
        order(%Q{#{has_lineage_options[:order]}})
      end
    end

    def lineage_filter(branch_id = nil)
      if branch_id.present? && has_lineage_options[:branch_key].present?
        where("#{has_lineage_options[:branch_key]} = ?", branch_id) 
      else
        all
      end
    end

    def new_lineage_path(prefix, raw_index)
      prefix.to_s + "#{has_lineage_options[:delimiter]}%0#{has_lineage_options[:leaf_width]}d" % (raw_index + 1)
    end

    def reset_lineage_tree(tree_branch_id = nil, &block)
      yield if block
      roots.lineage_filter(tree_branch_id).lineage_order(false).each_with_index do |sibling, index|
        sibling.lineage_path = new_lineage_path(nil, index)
        sibling.reset_tree if sibling.children?
      end
    end

  end
end