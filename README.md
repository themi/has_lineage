# HasLineage

A gem to manage hierarchical data.  This gem uses the Adjacency pattern to form the relationship and Materialised Path pattern for lookup.

I used this project as a training exercise to create a gem for a Rails project.  As a training project, it is not full featured and currently is not my intention to make it so. Though as its creator I will keep an open communication line to this project - contact me with your feedback.

The strategies I selected were from a an earlier project (15years ago) that appeared to me as being efficient.  BTW the reason Materialised Path is fast for _lookup_ is that it uses an ordered btree index on the records ancestry line.

Anyway, I choose to use Materialised Path because of the quick lookup times.  Additionly, I wanted to use the path to be the primary order.  

![tree sample diagram](http://hemi.co.nz/signature/has_lineage_tree_path_diag.png)

## Other Hierarchy strategies

So whats the best? Well in researching this subject I have found the following startegies for handling hierarchical data:

#### Adjacency List
* Each record has a key to its immediate parent.

#### Materialised Path / Path Enumeration
* Each record has a field containing complete line of its ancestry all the way up to the root.

#### Nested Sets.
* Each record has keys to the record immediatly left and right of its position the hierarchical chain.

#### Closure Table
* The complete line of its ancestry all the way up to the root is maintained as separate records in a separate table.

## How do they stack up against each other

Plenty of smarter people than I have already done this - take a look:

* [Taxonomic Trees in PostgreSQL](http://gbif.blogspot.com.au/2012/06/taxonomic-trees-in-postgresql.html)
* [Models for hierarchical data by Bill Karwin](http://www.slideshare.net/billkarwin/models-for-hierarchical-data)
* [Trees In The Database - Advanced data structures by Lorenzo Alberton](http://www.slideshare.net/quipo/trees-in-the-database-advanced-data-structures)

## Summary

Each one has its own particular strengths and your choice should be guided by how you are using your data/tree.  Me, I am leaning toward Closure Table as it separates the admin from the actual data file and sets you up to take advantage an ordered btree index (like Materialised Path does).

## Other gems

If there are others that I havent listed here please let me know and I'll add them.

* [Ancestry](https://github.com/stefankroes/ancestry)
* [Use PostgreSQL LTREE type with ActiveRecord](https://github.com/RISCfuture/hierarchy)
* [Closure Tree](https://github.com/mceachen/closure_tree)
* [Acts as tree for Rails 3](https://github.com/kristianmandrup/acts_as_tree_rails3)

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
update_children_recursive   reset the tree from the record's parent down to last descendant
move_to(destination_parent) move this record to another.  Also updates bothe source and 
                            destination tress
```

```
Klass.reset_lineage_tree    Reset the entire tree
```


### Options for has_lineage

```
:parent_key       foreign key to the parent record, defaults to :parent_id
:lineage_column   column_name storing the ancestry path, defaults to :lineage 
:leaf_width       the length of each ancestry path key, defaults to 4.
                  4 means: max siblings 9999, ~ max tree depth of 51 levels. 
:delimiter        the path separtor, defaults to '/'
:branch_key       foreign key to separate trees, defaults to nil (no separation).
                  use this option to add another foreign key so as to categorize 
                  or differentiate trees.
:order            column name used to order the siblings, defaults to nil 
:counter_cache    true/false, defaults to false. use to use Rails counter_cache
                  if true must add field :lineage_children_count to table
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
