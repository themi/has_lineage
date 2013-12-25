module HasLineage
  module ClassMethods

    def has_lineage options = {}

      valid_has_lineage_options(options, :parent_key, :lineage_column, :leaf_width, :delimiter, :branch_key, :order, :counter_cache)

      self.has_lineage_options = { 
              :parent_key => "parent_id", 
              :lineage_column => "lineage", 
              :leaf_width => 4, 
              :delimiter => '/',
              :branch_key => nil, 
              :order => nil, 
              :counter_cache => false }.update(options)

    end

    def valid_has_lineage_options options, *keys
      raise "Options for has_lineage must be in a hash." unless options.is_a? Hash

      options.each do |key, value|
        unless keys.include? key
          raise "Unknown option for has_lineage: #{key.inspect} => #{value.inspect}."
        end
      end
    end
    private :valid_has_lineage_options

  end
end