require 'spec_helper'
require 'database_helper'

describe Post, ".lineage_path" do
  context "with single hierarchy tree" do
    before do
      setup_db 
      Post.has_lineage
      @b1 = seed_basic_tree
      @b1.each { |k, v| v.reload }
    end

    after  { teardown_db }

    it "sets correct lineage path for the tree" do
      expect(@b1[:harry].lineage_path).to eq("/0001") 
      expect(@b1[:mary].lineage_path).to eq("/0001/0001")
      expect(@b1[:john].lineage_path).to eq("/0001/0002")
      expect(@b1[:larry].lineage_path).to eq("/0001/0002/0001")
      expect(@b1[:gina].lineage_path).to eq("/0001/0002/0002")
    end
  end

  context "with multiple hierarchy trees" do
    before do
      setup_db 
      Post.has_lineage({tree_key_column: 'tree_id'})
      @b1 = seed_basic_tree(1)
      @b1.each { |k, v| v.reload }
      @b2 = seed_basic_tree(2)
      @b2.each { |k, v| v.reload }
      @b3 = seed_basic_tree(1)
      @b3.each { |k, v| v.reload }
    end

    after  { teardown_db }

    it "sets correct lineage path for first tree" do
      expect(@b1[:harry].lineage_path).to eq("1/0001") 
      expect(@b1[:mary].lineage_path).to eq("1/0001/0001")
      expect(@b1[:john].lineage_path).to eq("1/0001/0002")
      expect(@b1[:larry].lineage_path).to eq("1/0001/0002/0001")
      expect(@b1[:gina].lineage_path).to eq("1/0001/0002/0002")
    end

    it "sets correct lineage path for second tree" do
      expect(@b2[:harry].lineage_path).to eq("2/0001") 
      expect(@b2[:mary].lineage_path).to eq("2/0001/0001")
      expect(@b2[:john].lineage_path).to eq("2/0001/0002")
      expect(@b2[:larry].lineage_path).to eq("2/0001/0002/0001")
      expect(@b2[:gina].lineage_path).to eq("2/0001/0002/0002")
    end

    it "sets correct lineage path for third tree" do
      expect(@b3[:harry].lineage_path).to eq("1/0002") 
      expect(@b3[:mary].lineage_path).to eq("1/0002/0001")
      expect(@b3[:john].lineage_path).to eq("1/0002/0002")
      expect(@b3[:larry].lineage_path).to eq("1/0002/0002/0001")
      expect(@b3[:gina].lineage_path).to eq("1/0002/0002/0002")
    end

  end
end