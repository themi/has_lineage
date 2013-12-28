class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :linage, :string
    add_column :<%= table_name %>, :lineage_children_count, :integer
    add_column :<%= table_name %>, :parent_id, :integer
    add_column :<%= table_name %>, :branch_id, :integer
  end

  add_index :<%= table_name %>, :lineage
  add_index :<%= table_name %>, :parent_id
  add_index :<%= table_name %>, :branch_id
end
