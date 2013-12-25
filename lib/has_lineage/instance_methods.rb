module HasLineage
  module LineageInstanceMethods

    def ancestors
      self.class.ancestors_for(lineage_path).order_by - [self]
    end

    def descendants(exclude_self = true)
      results = self.class.descendants_of(lineage_path).order_by
      results = results.where("id != ?", id) if exclude_self
      results
    end

    def root
      self.class.root_for(lineage_path)
    end

    def siblings
      self_and_siblings - [self]
    end

    def self_and_siblings
      lineage_parent ? lineage_parent.lineage_children.order_by : self.class.roots.lineage_filter(tree_branch_id).order_by
    end

    def children?
      lineage_children.size > 0
    end

    def parent?
      lineage_parent.present?
    end

    def reset_tree(prefix = lineage_path)
      lineage_children.lineage_filter(tree_branch_id).order_by(false).each_with_index do |sibling, index|
        sibling.lineage_path = self.class.new_lineage_path(prefix, index)
        sibling.reset_tree if children?
      end
    end

    def reset_my_tree
      if lineage_parent.present?
        lineage_parent.lineage_children.lineage_filter(tree_branch_id).order_by(false).each_with_index do |sibling, index|
          sibling.lineage_path = self.class.new_lineage_path(lineage_parent.lineage_path, index)
          sibling.reset_tree if children?
        end
      else
        self.class.reset_lineage_tree
      end
    end

    def lineage_path
      send(has_lineage_options[:lineage_column])
    end

    def lineage_path=(value)
      update_column(has_lineage_options[:lineage_column].to_sym, value)
    end

    # =====
    private
    # =====

    def tree_update_required?
      key_fields_changed? && valid? 
    end

    def key_fields_changed?
      changed.include?(has_lineage_options[:parent_key].to_s) ||
        changed.include?(has_lineage_options[:order].to_s)
    end

    def tree_branch_id
      send(has_lineage_options[:branch_key]) if has_lineage_options[:branch_key].present?
    end

  end
end