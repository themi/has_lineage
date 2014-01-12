module HasLineage
  module LineageInstanceMethods

    def root
      self.class.root_for(lineage_path, lineage_tree_id)
    end

    def ancestors
      self.class.ancestors_for(lineage_path, lineage_tree_id).lineage_order - [self]
    end

    def descendants
      self_and_descendants - [self]
    end

    def self_and_descendants
      self.class.descendants_of(lineage_path, lineage_tree_id).lineage_order
    end
    alias :subtree :self_and_descendants

    def siblings
      self_and_siblings - [self]
    end

    def self_and_siblings
      (lineage_parent.present? ? lineage_parent.lineage_children.lineage_tree(lineage_tree_id) : self.class.roots(lineage_tree_id)).lineage_order
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

    def parent
      lineage_parent
    end

    def update_child_paths_recursive(prefix = lineage_path)
      lineage_children.lineage_tree(lineage_tree_id).presort_order.each_with_index do |sibling, index|
        sibling.lineage_path = self.class.new_lineage_path(prefix, index)
        sibling.update_child_paths_recursive if children?
      end
    end

    def lineage_path
      send(self.class.send(:lineage_column_name))
    end

    def lineage_path=(value)
      update_column(self.class.send(:lineage_column_name).to_sym, value)
    end

    def parent_key_changed?
      send("#{self.class.send(:parent_column_name)}_changed?")
    end

    def hierarchy_depth
      return 0 if lineage_path.nil?
      self.class.hierachy_depth_for(lineage_path)
    end
    alias :depth :hierarchy_depth

    def move_to(dest_parent)
      ok_to_move_to?(dest_parent)

      dest_parent_id = dest_parent.id
      old_parent_id = lineage_parent.id

      update_key_attributes(dest_parent)

      self.class.find(old_parent_id).update_child_paths_recursive
      self.class.find(dest_parent_id).update_child_paths_recursive
    end

    # =====
    protected
    # =====

      def lineage_tree_id
        send(self.class.send(:tree_column_name)) if self.class.send(:tree_column_name).present?
      end

    # =====
    private
    # =====

      def ok_to_move_to?(dest_parent)
        raise MoveException.new("Cannot move root node!") unless parent?
        raise MoveException.new("Cannot move to another tree!") if lineage_tree_id != dest_parent.lineage_tree_id
        raise MoveException.new("Cannot move to a descendant node!") if dest_parent.lineage_path.starts_with?(lineage_path)
      end

      def update_key_attributes(dest_parent)
        attribs = { :lineage_parent => dest_parent }
        attribs.merge!({ self.class.send(:tree_column_name).to_sym => dest_parent.send(self.class.send(:tree_column_name)) }) if self.class.send(:tree_column_name).present?
        update_attributes(attribs)
      end

  end
end