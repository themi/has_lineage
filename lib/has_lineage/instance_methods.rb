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

    def siblings
      self_and_siblings - [self]
    end

    def self_and_siblings
      (lineage_parent.present? ? lineage_parent.lineage_children.lineage_filter(lineage_tree_id) : self.class.roots(lineage_tree_id)).lineage_order
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

    def update_children_recursive(prefix = lineage_path)
      lineage_children.lineage_filter(lineage_tree_id).presort_order.each_with_index do |sibling, index|
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

    def parent_key_changed?
      send("#{has_lineage_options[:parent_key_column]}_changed?")
    end

    def hierarchy_depth
      return 0 if lineage_path.nil?
      lineage_path.split(has_lineage_options[:delimiter]).size - 1
    end
    alias :depth :hierarchy_depth

    def move_to(dest_parent)
      raise MoveException.new("Cannot move root node!") unless parent?
      raise MoveException.new("Cannot move to another tree!") if lineage_tree_id != dest_parent.lineage_tree_id
      raise MoveException.new("Cannot move to a descendant node!") if dest_parent.lineage_path.starts_with?(lineage_path)

      dest_parent_id = dest_parent.id
      old_parent_id = lineage_parent.id

      attribs = { :lineage_parent => dest_parent }
      attribs.merge!({ has_lineage_options[:tree_key_column].to_sym => dest_parent.send(has_lineage_options[:tree_key_column]) }) if has_lineage_options[:tree_key_column]

      update_attributes(attribs)

      self.class.find(old_parent_id).update_children_recursive
      self.class.find(dest_parent_id).update_children_recursive
    end

    # =====
    protected
    # =====

      def lineage_tree_id
        send(has_lineage_options[:tree_key_column]) if has_lineage_options[:tree_key_column].present?
      end

  end
end