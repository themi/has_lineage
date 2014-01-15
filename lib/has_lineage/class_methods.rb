require 'active_support/core_ext/array/conversions'

module HasLineage
  module LineageClassMethods

    def roots(tree_id = nil)
      lineage_tree(tree_id).where(parent_column_name.to_sym => nil)
    end

    def root_for(path, tree_id = nil)
      lineage_tree(tree_id).where(lineage_column_name.to_sym => root_path_for(path)).first
    end

    def ancestors_for(path, tree_id = nil)
      lineage_tree(tree_id).where(lineage_column_name.to_sym => ancestor_array_for(path))
    end

    def descendants_of(path, tree_id = nil)
      lineage_tree(tree_id).where("#{lineage_column_name} LIKE ?", "#{path}%")
    end

    def presort_order
      order(%Q{#{order_columns}})
    end

    def lineage_order
      order(lineage_column_name.to_sym)
    end

    def lineage_tree(tree_id = nil)
      if tree_id.present? && tree_column_name.present?
        where(tree_column_name.to_sym => tree_id) 
      else
        all
      end
    end

    def new_lineage_path(prefix, raw_index)
      prefix.to_s + path_pattern(raw_index+1) 
    end

    def reset_lineage_tree(tree_id = nil, &block)
      yield if block_given?

      if connection.adapter_name =~ /postgresql/i
        connection.execute reset_tree_pg
      else 
        reset_tree_recursive
      end
    end

    def hierachy_depth_for(path)
      array_for(path).size - 1
    end

    # =====
    private
    # =====

    def array_for(path)
      path.split("#{path_delimiter}")
    end

    def path_pattern(index)
      "#{path_delimiter}%0#{path_leaf_width}d" % index
    end

    def root_path_for(path)
      path_array = array_for(path)
      path_array[0] + path_pattern(path_array[1].to_i) 
    end

    def reset_tree_recursive(tree_id = nil)
      distinct_tree_values(tree_id).each do |tree_id|
        roots(tree_id).presort_order.each_with_index do |sibling, index|
          prefix = sibling.send(tree_column_name) if tree_column_name.present?
          sibling.lineage_path = new_lineage_path(prefix, index)
          sibling.reset_lineage_tree if sibling.children?
        end
      end
    end

    def ancestor_array_for(path)
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
      if tree_column_name.present?
        key = tree_column_name.to_sym
        roots.select(key).distinct.order(key).pluck(key)
      else
        [nil]
      end
    end

  end
end