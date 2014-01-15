require 'spec_helper'
require 'database_helper'

describe Post, "Class SQL" do

  def string_with
    <<-STRING_DATA
WITH RECURSIVE hierachy_tree(path, id, parent_id) AS (
SELECT path_parents.tree_id || '/' || ltrim(to_char(sibling_index, repeat('0',4))) AS path, path_parents.id, path_parents.parent_id FROM (
SELECT row_number() OVER (PARTITION BY posts.tree_id ORDER BY posts.tree_id, posts.name) AS sibling_index, posts.id, posts.parent_id AS parent_id, posts.tree_id AS tree_id
FROM posts
WHERE posts.parent_id IS NULL
) as path_parents

UNION ALL
SELECT hierachy_tree.path || '/' || ltrim(to_char(sibling_index, repeat('0',4))) AS path, path_users.id, path_users.parent_id FROM (
SELECT row_number() OVER (PARTITION BY posts.parent_id ORDER BY posts.name) AS sibling_index, posts.id, posts.parent_id AS parent_id
FROM posts
WHERE posts.parent_id > 0

) as path_users
INNER JOIN hierachy_tree ON path_users.parent_id = hierachy_tree.id
)
UPDATE posts SET lineage = hierachy_tree.path FROM hierachy_tree WHERE hierachy_tree.id = posts.id;
STRING_DATA
  end

  def string_without
    <<-STRING_DATA
WITH RECURSIVE hierachy_tree(path, id, parent_id) AS (
SELECT path_parents.tree_id || '/' || ltrim(to_char(sibling_index, repeat('0',4))) AS path, path_parents.id, path_parents.parent_id FROM (
SELECT row_number() OVER (PARTITION BY '' ORDER BY '', posts.name) AS sibling_index, posts.id, posts.parent_id AS parent_id, '' AS tree_id
FROM posts
WHERE posts.parent_id IS NULL
) as path_parents

UNION ALL
SELECT hierachy_tree.path || '/' || ltrim(to_char(sibling_index, repeat('0',4))) AS path, path_users.id, path_users.parent_id FROM (
SELECT row_number() OVER (PARTITION BY posts.parent_id ORDER BY posts.name) AS sibling_index, posts.id, posts.parent_id AS parent_id
FROM posts
WHERE posts.parent_id > 0

) as path_users
INNER JOIN hierachy_tree ON path_users.parent_id = hierachy_tree.id
)
UPDATE posts SET lineage = hierachy_tree.path FROM hierachy_tree WHERE hierachy_tree.id = posts.id;
STRING_DATA
  end

  context "with tree key" do
    before { setup_db; described_class.has_lineage :tree_key_column => 'tree_id' }
    after  { teardown_db }

    it "returns sql incl tree_id partition" do
      expect( described_class.send(:reset_tree_pg) ).to eq(string_with)
    end
  end

  context "without tree key" do
    before { setup_db; described_class.has_lineage }
    after  { teardown_db }

    it "returns sql excl tree_id partition" do
      expect( described_class.send(:reset_tree_pg) ).to eq(string_without)
    end
  end
end
