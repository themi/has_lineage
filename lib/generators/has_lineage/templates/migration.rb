class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :lineage, :string
    add_column :<%= table_name %>, :parent_id, :integer               # Remove if parent key already set
    add_column :<%= table_name %>, :tree_id, :integer                 # Remove if only one tree hierarchy needed
    add_column :<%= table_name %>, :lineage_children_count, :integer  # Remove if cache_count not required

    add_index :<%= table_name %>, :lineage
    add_index :<%= table_name %>, :parent_id                          # Remove if parent key already set
    add_index :<%= table_name %>, :tree_id                            # Remove if only one tree hierarchy needed
  end
end
