require 'active_record'

class Post < ActiveRecord::Base
  include HasLineage
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  # suppress schema load notifications
  $stdout_orig = $stdout
  $stdout = StringIO.new

  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts, force: true do |t|
      t.column :name, :string
      t.column :parent_id, :integer
      t.column :lineage, :string
      t.column :tree_id, :integer
      t.column :lineage_children_count, :integer
    end
  end

  $stdout = $stdout_orig 
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

def seed_basic_tree(tree_id)
  harry = Post.create(:name => "Harry_#{tree_id}", tree_id: tree_id)
  mary = Post.create(:name => "Mary_#{tree_id}", tree_id: tree_id)
  john = Post.create(:name => "John_#{tree_id}", tree_id: tree_id)
  jane = Post.create(:name => "Jane_#{tree_id}", tree_id: tree_id)
  larry = Post.create(:name => "Larry_#{tree_id}", tree_id: tree_id)
  gina = Post.create(:name => "Gina_#{tree_id}", tree_id: tree_id)
  Post.reset_lineage_tree do
    harry.lineage_children << mary
    harry.lineage_children << john
    harry.lineage_children << jane
    john.lineage_children << larry
    john.lineage_children << gina
  end
  { harry: harry, mary: mary, jane: jane, john: john, larry: larry, gina: gina }
end

