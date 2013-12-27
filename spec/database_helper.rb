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
      t.column :branch_id, :integer
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

