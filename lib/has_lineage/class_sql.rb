module HasLineage
  module LineageClassSql

    def tree_table_column_name
      if tree_column_name
        "#{table_name}.#{tree_column_name}" 
      else
        "''"
      end
    end
    private :tree_table_column_name

    def parent_table_column_name
      "#{table_name}.#{parent_column_name}"
    end
    private :parent_table_column_name

    def root_sub_select_pg
<<-SQL
SELECT path_parents.tree_id || '#{path_delimiter}' || ltrim(to_char(sibling_index, repeat('0',#{path_leaf_width}))) AS path, path_parents.id, path_parents.parent_id FROM (
SELECT row_number() OVER (PARTITION BY #{tree_table_column_name} ORDER BY #{tree_table_column_name}, #{table_name}.name) AS sibling_index, #{table_name}.id, #{parent_table_column_name} AS parent_id, #{tree_table_column_name} AS tree_id
FROM #{table_name}
WHERE #{parent_table_column_name} IS NULL
) as path_parents
SQL
    end
    private :root_sub_select_pg

    def children_sub_select_pg
<<-SQL
SELECT row_number() OVER (PARTITION BY #{parent_table_column_name} ORDER BY #{table_name}.name) AS sibling_index, #{table_name}.id, #{parent_table_column_name} AS parent_id
FROM #{table_name}
WHERE #{parent_table_column_name} > 0
SQL
    end
    private :children_sub_select_pg

    def reset_tree_pg
<<-SQL
WITH RECURSIVE hierachy_tree(path, id, parent_id) AS (
#{root_sub_select_pg}
UNION ALL
SELECT hierachy_tree.path || '#{path_delimiter}' || ltrim(to_char(sibling_index, repeat('0',#{path_leaf_width}))) AS path, path_users.id, path_users.parent_id FROM (
#{children_sub_select_pg}
) as path_users
INNER JOIN hierachy_tree ON path_users.parent_id = hierachy_tree.id
)
UPDATE #{table_name} SET lineage = hierachy_tree.path FROM hierachy_tree WHERE hierachy_tree.id = #{table_name}.id;
SQL
    end
    private :reset_tree_pg

  end
end