module HasLineage
  module LineageClassOptions

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

      belongs_to :lineage_parent, :class_name => name, :foreign_key => parent_column_name, :counter_cache => has_lineage_options[:counter_cache]
      has_many :lineage_children, :class_name => name, :foreign_key => parent_column_name, :dependent => :destroy
    end

    def tree_column_name
      has_lineage_options[:tree_key_column]
    end
    private :tree_column_name

    def parent_column_name 
      has_lineage_options[:parent_key_column]
    end
    private :parent_column_name

    def lineage_column_name
      has_lineage_options[:lineage_column]
    end
    private :lineage_column_name

    def path_leaf_width
      has_lineage_options[:leaf_width]
    end
    private :path_leaf_width

    def path_delimiter
      has_lineage_options[:delimiter]
    end
    private :path_delimiter

    def order_columns
      has_lineage_options[:order_column]
    end
    private :order_columns

  end
end