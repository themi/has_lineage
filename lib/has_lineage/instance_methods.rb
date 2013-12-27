module HasLineage
  module LineageInstanceMethods

    def root
      self.class.root_for(lineage_path, tree_branch_id)
    end

    def ancestors
      self.class.ancestors_for(lineage_path, tree_branch_id).lineage_order - [self]
    end

    def descendants
      self_and_descendants - [self]
    end

    def self_and_descendants
      self.class.descendants_of(lineage_path, tree_branch_id).lineage_order
    end

    def siblings
      self_and_siblings - [self]
    end

    def self_and_siblings
      (lineage_parent.present? ? lineage_parent.lineage_children.lineage_filter(tree_branch_id) : self.class.roots(tree_branch_id)).lineage_order
    end

    def children?
      lineage_children.size > 0
    end

    def children
      lineage_children
    end

    def parent?
      lineage_parent.present?
    end

    def update_children_recursive(prefix = lineage_path)
      lineage_children.lineage_filter(tree_branch_id).presort_order.each_with_index do |sibling, index|
        sibling.lineage_path = self.class.new_lineage_path(prefix, index)
        sibling.update_children_recursive if children?
      end
    end

    def lineage_path
      send(has_lineage_options[:lineage_column])
    end

    def lineage_path=(value)
      update_column(has_lineage_options[:lineage_column].to_sym, value)
    end

    def reset_lineage_tree
      self.class.reset_lineage_tree(branch_id)
    end

    # =====
    private
    # =====

    def tree_branch_id
      send(has_lineage_options[:branch_key]) if has_lineage_options[:branch_key].present?
    end

  end
end