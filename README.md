[![Build Status](https://travis-ci.org/themi/has_lineage.png?branch=master)](https://travis-ci.org/themi/has_lineage)
[![Coverage Status](https://coveralls.io/repos/themi/has_lineage/badge.png)](https://coveralls.io/r/themi/has_lineage)

# HasLineage

Rails hierarchical modelling tool. Using Materialised Path for fast lookup (also doubles as a sort order).  In addition, the Adjacency pattern is used to maintain referencial integrity to allow the path to be re-adjusted as changes inevidably occur.

Initially (using Adjacency) I was frustrated by lengthy retrevial times of large trees so I tried out Materialised Path which was lightning quick at retreval but awkward when the tree was modified.  And Adjency was needed to maintain referential integrity while the Materialised path was being re-adjusted.

![tree sample diagram](http://hemi.co.nz/signature/has_lineage_tree_path_diag.png)

## Installation

Add this line to your application's Gemfile:

    gem 'has_lineage'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_lineage

## Usage

#### Run migration

```bash
rails generate has_lineage:migration Post
```

adjust the migration file as required, then...

```bash
rake db:migrate
```

#### Add to your model

```ruby
class Post < ActiveRecord::Base
  include HasLineage
  has_lineage
end

```

#### Setup your tree

```ruby
harry = Post.create(:name => "Harry")
mary = Post.create(:name => "Mary")
john = Post.create(:name => "John")
jane = Post.create(:name => "Jane")
larry = Post.create(:name => "Larry")
gina = Post.create(:name => "Gina")
Post.reset_lineage_tree do
  harry.children << mary
  harry.children << john
  harry.children << jane
  john.children << larry
  john.children << gina
end
```

I have not included call_backs to update tree automatically, as maintaining indexes on the lineage path column can be expensive.  Updating the tree should a be a process on its own and once done editing, then reset the tree/s.

### Navigating

```
root             Returns the root of the tree the record is in, self for a root node
parent           Returns the parent of the record, nil for a root node
ancestors        Returns a list of ancestors of the record, self is not included
children         Returns children of the record
siblings         Returns siblings of the record, the record itself is not included
descendants      Returns direct and indirect children of the record, self is not included
```

```
children?                   are there any children for this record
parent?                     is there a parent record for this record
reset_lineage_tree          reset the tree from the record's parent down to last descendant
move_to(destination_parent) move this record to another.  Also updates bothe source and 
                            destination tress
```

```
Klass.reset_lineage_tree    Reset the entire tree
```


### Options for has_lineage

```
:parent_key_column foreign key to the parent record, defaults to :parent_id
:lineage_column    column_name storing the ancestry path, defaults to :lineage 
:leaf_width        the length of each ancestry path key, defaults to 4.
                   4 means: max siblings 9999, ~ max tree depth of 51 levels with 256 byte string. 
:delimiter         the path separtor, defaults to '/'
:tree_key_column   foreign key or value that separates trees, defaults to nil.
                   use this option to categorize or differentiate trees.
:order_column      column name used to order the siblings, defaults to nil 
:counter_cache     true/false, defaults to false. use to use Rails counter_cache
                   if true must add field :lineage_children_count to table
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Other Hierarchy strategies

I started this project as a training exercise and in the process picked up more data on hierarchical patterns. That research yeilded the following:

#### Adjacency List
* Each record has a key to its immediate parent.

#### Materialised Path / Path Enumeration
* Each record has a field containing complete line of its ancestry all the way up to the root.

#### Nested Sets.
* Each record has keys to the record immediatly left and right of its position the hierarchical chain.

#### Closure Table
* The complete line of its ancestry all the way up to the root is maintained as separate records in a separate table.

## How do they stack up against each other

Here are comparisons:

* [Recursive Data Structures With Rails](http://gmarik.info/blog/2012/10/14/recursive-data-structures-with-rails)
* [Taxonomic Trees in PostgreSQL](http://gbif.blogspot.com.au/2012/06/taxonomic-trees-in-postgresql.html)
* [Models for hierarchical data by Bill Karwin](http://www.slideshare.net/billkarwin/models-for-hierarchical-data)
* [Trees In The Database - Advanced data structures by Lorenzo Alberton](http://www.slideshare.net/quipo/trees-in-the-database-advanced-data-structures)

## Summary

Each one has its own particular strengths and your choice should be guided by how you are using your data/tree.  Me, I am leaning toward Closure Table as it separates the admin from the actual data file and sets you up to take advantage an ordered btree index (e.g. Materialised Path). I have not made immediate plans to move this gem in that direction as yet, especially since another developer has already done so.

## Other gems

Here are other gems that handle this particular problem and based on the various patterns mentioned above:

* [Ancestry](https://github.com/stefankroes/ancestry)
* [Use PostgreSQL LTREE type with ActiveRecord](https://github.com/RISCfuture/hierarchy)
* [Closure Tree](https://github.com/mceachen/closure_tree)
* [An awesome replacement for acts_as_nested_set](https://github.com/collectiveidea/awesome_nested_set)
* [Acts as tree for Rails 3](https://github.com/kristianmandrup/acts_as_tree_rails3)

