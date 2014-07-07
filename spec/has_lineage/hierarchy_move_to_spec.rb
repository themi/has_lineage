require 'spec_helper'
require 'database_helper'

describe Post, "#move_to" do
  before { setup_db; Post.has_lineage({tree_key_column: 'tree_id', order_column: :name})  }
  after  { teardown_db }

  context "with hierarchy tree" do
    before do
      @b1 = seed_basic_tree(1)
      @b1.each { |k, v| v.reload }
      @b2 = seed_basic_tree(2)
      @b2.each { |k, v| v.reload }
    end

    specify "with root node raises MoveException" do
      expect { @b1[:harry].move_to(@b2[:harry]) }.to raise_error(HasLineage::MoveException, "Cannot move root node!")
    end

    specify "With another tree node raise MoveException" do
      expect { @b1[:mary].move_to(@b2[:john]) }.to raise_error(HasLineage::MoveException, "Cannot move to another tree!")
    end

    specify "with decendant node raises MoveException" do
      expect { @b1[:john].move_to(@b1[:gina]) }.to raise_error(HasLineage::MoveException, "Cannot move to a descendant node!")
    end

    specify "with acceptable branch node doesnot reaise error " do
      expect { @b1[:mary].move_to(@b1[:john]) }.to_not raise_error
    end

    specify "with acceptable branch node updates the paths" do
      expect( @b1[:john].lineage_path ).to eq("1/0001/0002")
      expect( @b1[:jane].lineage_path ).to eq("1/0001/0001")

      @b1[:jane].move_to(@b1[:john])
      @b1[:john].reload
      expect( @b1[:john].lineage_path ).to eq("1/0001/0001")
      @b1[:jane].reload
      expect( @b1[:jane].lineage_path ).to eq("1/0001/0001/0002")
    end

  end

end