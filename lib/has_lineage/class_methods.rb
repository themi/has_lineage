require 'active_support/core_ext/array/conversions'

module HasLineage
  module LineageClassMethods

    def has_lineage options = {}

      raise HasLineage::GeneralException.new("Options for has_lineage must be in a hash.") unless options.is_a? Hash

      options.assert_valid_keys(:parent_key, :lineage_column, :leaf_width, :delimiter, :branch_key, :order, :counter_cache)

      self.has_lineage_options = { 
              :parent_key => "parent_id", 
              :lineage_column => "lineage", 
              :leaf_width => 4, 
              :delimiter => '/',
              :branch_key => nil, 
              :order => nil, 
              :counter_cache => false }.update(options)

      self._pending_tree_refresh = false

      belongs_to :lineage_parent, :class_name => name, :foreign_key => has_lineage_options[:parent_key], :counter_cache => has_lineage_options[:counter_cache]
      has_many :lineage_children, :class_name => name, :foreign_key => has_lineage_options[:parent_key], :dependent => :destroy
    end

    def roots(branch_id = nil)
      lineage_filter(branch_id).where("#{has_lineage_options[:parent_key]} IS NULL")
    end

    def root_for(path, branch_id = nil)
      return nil unless path.present?
      root_index = array_for(path)[0].to_i
      lineage_filter(branch_id).where("#{has_lineage_options[:lineage_column]} = ?", path_pattern(root_index)).first
    end

    def ancestors_for(path, branch_id = nil)
      return [] unless path.present?
      lineage_filter(branch_id).where("#{has_lineage_options[:lineage_column]} IN (?)", progressive_array_for(path))
    end

    def descendants_of(path, branch_id = nil)
      if path.present?
        lineage_filter(branch_id).where("#{has_lineage_options[:lineage_column]} LIKE ?", "#{path}%")
      else
        lineage_filter(branch_id)
      end
    end

    def presort_order
      order(%Q{#{has_lineage_options[:order]}})
    end

    def lineage_order
      order(%Q{#{has_lineage_options[:lineage_column]}})
    end

    def lineage_filter(branch_id = nil)
      if branch_id.present? && has_lineage_options[:branch_key].present?
        where("#{has_lineage_options[:branch_key]} = ?", branch_id) 
      else
        all
      end
    end

    def new_lineage_path(prefix, raw_index)
      prefix.to_s + path_pattern(raw_index+1) 
    end

    def reset_lineage_tree(branch_id = nil, &block)
      _pending_tree_refresh = true
      yield if block_given?
      _pending_tree_refresh = false
      roots(branch_id).presort_order.each_with_index do |sibling, index|
        sibling.lineage_path = new_lineage_path(nil, index)
        sibling.update_children_recursive if sibling.children?
      end
    end

    # =====
    private
    # =====

    def array_for(value)
      value.split("#{has_lineage_options[:delimiter]}").reject { |a| a.empty? }
    end

    def path_pattern(index)
      "#{has_lineage_options[:delimiter]}%0#{has_lineage_options[:leaf_width]}d" % index
    end

    def progressive_array_for(path)
      arr = array_for(path)
      result = []
      new_path = ""
      arr.each_with_index do |a, index|
        new_path << path_pattern(a.to_i)
        result << new_path.clone
      end
      result
    end

  end
end