require 'spec_helper'
require 'database_helper'

describe Post, "#move_to" do
  before { setup_db; Post.has_lineage({branch_key: 'branch_id'})  }
  after  { teardown_db }

  context "with hierarchy tree" do
    before do
      @b1 = seed_basic_tree(1)
      @b1.each { |k, v| v.reload }
      @b2 = seed_basic_tree(2)
      @b2.each { |k, v| v.reload }
    end

    it "with root node raises error" do
      expect { @b1[:harry].move_to(@b2[:harry]) }.to raise_error(HasLineage::MoveException, "Cannot move root node!")
    end

    it "cannot move to another tree" do
      expect { @b1[:mary].move_to(@b2[:john]) }.to raise_error(HasLineage::MoveException, "Cannot move to another tree!")
    end

    it "cannot move to one of its decendant" do
      expect { @b1[:john].move_to(@b1[:gina]) }.to raise_error(HasLineage::MoveException, "Cannot move to a descendant node!")
    end

    it "no error when move to another branch" do
      expect { @b1[:mary].move_to(@b1[:john]) }.to_not raise_error
    end

    it "changes path when move to another branch" do
      expect( @b1[:mary].lineage_path ).to eq("/0001/0001")
      @b1[:mary].move_to(@b1[:john])
      @b1[:mary].reload
      expect( @b1[:mary].lineage_path ).to eq("/0001/0002/0001")
    end

    it "informs developer to use #move_to"

  end

end