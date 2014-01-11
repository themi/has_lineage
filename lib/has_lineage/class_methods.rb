require 'active_support/core_ext/array/conversions'

module HasLineage
  module LineageClassMethods

    def has_lineage options = {}

      raise HasLineage::GeneralException.new("Options for has_lineage must be in a hash.") unless options.is_a? Hash

      options.assert_valid_keys(:parent_key_column, :lineage_column, :leaf_width, :delimiter, :tree_key_column, :order_column, :counter_cache)

      self.has_lineage_options = { 
              :parent_key_column => "parent_id", 
              :lineage_column => "lineage", 
              :leaf_width => 4, 
              :delimiter => '/',
              :tree_key_column => nil, 
              :order_column => nil, 
              :counter_cache => false }.update(options)

      belongs_to :lineage_parent, :class_name => name, :foreign_key => has_lineage_options[:parent_key_column], :counter_cache => has_lineage_options[:counter_cache]
      has_many :lineage_children, :class_name => name, :foreign_key => has_lineage_options[:parent_key_column], :dependent => :destroy
    end

    def roots(tree_id = nil)
      lineage_filter(tree_id).where("#{has_lineage_options[:parent_key_column]} IS NULL")
    end

    def root_for(path, tree_id = nil)
      path_array = array_for(path)
      root_path = path_array[0] + path_pattern(path_array[1].to_i) 
      lineage_filter(tree_id).where("#{has_lineage_options[:lineage_column]} = ?", root_path).first
    end

    def ancestors_for(path, tree_id = nil)
      lineage_filter(tree_id).where("#{has_lineage_options[:lineage_column]} IN (?)", progressive_array_for(path))
    end

    def descendants_of(path, tree_id = nil)
      lineage_filter(tree_id).where("#{has_lineage_options[:lineage_column]} LIKE ?", "#{path}%")
    end

    def presort_order
      order(%Q{#{has_lineage_options[:order_column]}})
    end

    def lineage_order
      order(has_lineage_options[:lineage_column].to_sym)
    end

    def lineage_filter(tree_id = nil)
      if tree_id.present? && has_lineage_options[:tree_key_column].present?
        where(has_lineage_options[:tree_key_column].to_sym => tree_id) 
      else
        all
      end
    end

    def new_lineage_path(prefix, raw_index)
      prefix.to_s + path_pattern(raw_index+1) 
    end

    def reset_lineage_tree(tree_id = nil, &block)
      yield if block_given?

      distinct_tree_values(tree_id).each do |tree_id|
        roots(tree_id).presort_order.each_with_index do |sibling, index|
          prefix = sibling.send(has_lineage_options[:tree_key_column]) if has_lineage_options[:tree_key_column].present?
          sibling.lineage_path = new_lineage_path(prefix, index)
          sibling.update_children_recursive if sibling.children?
        end
      end
    end

    # =====
    private
    # =====

    def array_for(value)
      value.split("#{has_lineage_options[:delimiter]}")
    end

    def path_pattern(index)
      "#{has_lineage_options[:delimiter]}%0#{has_lineage_options[:leaf_width]}d" % index
    end

    def progressive_array_for(path)
      arr = array_for(path)
      result = []
      new_path = arr[0]
      arr.each_with_index do |a, index|
        next if index == 0
        new_path << path_pattern(a.to_i)
        result << new_path.clone
      end
      result
    end

    def distinct_tree_values(tree_id = nil)
      return [tree_id] if tree_id.present?
      if has_lineage_options[:tree_key_column].present?
        key = has_lineage_options[:tree_key_column].to_sym
        roots.select(key).distinct.order(key).pluck(key)
      else
        [nil]
      end
    end

  end
end