require 'spec_helper'
require 'database_helper'

describe Post, "Hierachy" do

  before { setup_db; Post.has_lineage({branch_key: 'branch_id'})  }
  after  { teardown_db }

  context "with complex hierarchy tree" do
    before do
      @b1 = seed_basic_tree(1)
      @b1.each { |k, v| v.reload }
      @b2 = seed_basic_tree(2)
      @b2.each { |k, v| v.reload }
      @b3 = seed_basic_tree(1)
      @b3.each { |k, v| v.reload }
    end

    it "sets correct lineage path for first branch" do
      expect(@b1[:harry].lineage_path).to eq("/0001") 
      expect(@b1[:mary].lineage_path).to eq("/0001/0001")
      expect(@b1[:john].lineage_path).to eq("/0001/0002")
      expect(@b1[:larry].lineage_path).to eq("/0001/0002/0001")
      expect(@b1[:gina].lineage_path).to eq("/0001/0002/0002")
    end

    it "sets correct lineage path for second branch" do
      expect(@b2[:harry].lineage_path).to eq("/0002") 
      expect(@b2[:mary].lineage_path).to eq("/0002/0001")
      expect(@b2[:john].lineage_path).to eq("/0002/0002")
      expect(@b2[:larry].lineage_path).to eq("/0002/0002/0001")
      expect(@b2[:gina].lineage_path).to eq("/0002/0002/0002")
    end

    it "sets correct lineage path for third branch" do
      expect(@b3[:harry].lineage_path).to eq("/0003") 
      expect(@b3[:mary].lineage_path).to eq("/0003/0001")
      expect(@b3[:john].lineage_path).to eq("/0003/0002")
      expect(@b3[:larry].lineage_path).to eq("/0003/0002/0001")
      expect(@b3[:gina].lineage_path).to eq("/0003/0002/0002")
    end

  end
end