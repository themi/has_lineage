require 'spec_helper'
require 'database_helper'

describe Post, "Hierachy" do
  def seed_tree(branch_id)
    harry = Post.create(:name => "Harry_#{branch_id}", branch_id: branch_id)
    mary = Post.create(:name => "Mary_#{branch_id}", branch_id: branch_id)
    john = Post.create(:name => "John_#{branch_id}", branch_id: branch_id)
    larry = Post.create(:name => "Larry_#{branch_id}", branch_id: branch_id)
    gina = Post.create(:name => "Gina_#{branch_id}", branch_id: branch_id)
    described_class.reset_lineage_tree do
      harry.lineage_children << mary
      harry.lineage_children << john
      john.lineage_children << larry
      john.lineage_children << gina
    end
    { harry: harry, mary: mary, john: john, larry: larry, gina: gina }
  end

  before { setup_db; described_class.has_lineage({branch_key: 'branch_id'})  }
  after  { teardown_db }

  context "with complex hierarchy tree" do
    before do
      @b1 = seed_tree(1)
      @b1.each { |k, v| v.reload }
      @b2 = seed_tree(2)
      @b2.each { |k, v| v.reload }
      @b3 = seed_tree(1)
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

    it "#root" do
      expect(@b1[:harry].root).to eq(@b1[:harry])
      expect(@b1[:mary].root).to eq(@b1[:harry])
      expect(@b1[:gina].root).to eq(@b1[:harry])

      expect(@b2[:harry].root).to eq(@b2[:harry])
      expect(@b2[:mary].root).to eq(@b2[:harry])
      expect(@b2[:gina].root).to eq(@b2[:harry])

      expect(@b3[:harry].root).to eq(@b3[:harry])
      expect(@b3[:mary].root).to eq(@b3[:harry])
      expect(@b3[:gina].root).to eq(@b3[:harry])

      expect(nil).to be_nil
    end


  end
end