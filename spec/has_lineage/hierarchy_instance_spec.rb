require 'spec_helper'
require 'database_helper'

describe Post, "Hierachy instance methods" do

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

    it "#ancestors" do
      expect(@b1[:harry].ancestors).to be_empty
      expect(@b1[:mary].ancestors).to include(@b1[:harry])
      expect(@b1[:gina].ancestors).to include(@b1[:harry], @b1[:john])

      expect(@b2[:harry].ancestors).to be_empty
      expect(@b2[:mary].ancestors).to include(@b2[:harry])
      expect(@b2[:gina].ancestors).to include(@b2[:harry], @b2[:john])

      expect(@b3[:harry].ancestors).to be_empty
      expect(@b3[:mary].ancestors).to include(@b3[:harry])
      expect(@b3[:gina].ancestors).to include(@b3[:harry], @b3[:john])
    end

    it "#descendants" do
      expect(@b1[:harry].descendants).to include(@b1[:mary], @b1[:john], @b1[:larry], @b1[:gina])
      expect(@b1[:mary].descendants).to be_empty
      expect(@b1[:john].descendants).to include(@b1[:larry], @b1[:gina])
      expect(@b1[:larry].descendants).to be_empty

      expect(@b2[:harry].descendants).to include(@b2[:mary], @b2[:john], @b2[:larry], @b2[:gina])
      expect(@b2[:mary].descendants).to be_empty
      expect(@b2[:john].descendants).to include(@b2[:larry], @b2[:gina])
      expect(@b2[:larry].descendants).to be_empty

      expect(@b3[:harry].descendants).to include(@b3[:mary], @b3[:john], @b3[:larry], @b3[:gina])
      expect(@b3[:mary].descendants).to be_empty
      expect(@b3[:john].descendants).to include(@b3[:larry], @b3[:gina])
      expect(@b3[:larry].descendants).to be_empty
    end

    it "#siblings" do
      paul = Post.create(:name => "Paul_4", branch_id: 4)

      expect(@b1[:harry].siblings.count).to eq(1)
      expect(@b1[:harry].siblings).to include(@b3[:harry])
      expect(@b1[:gina].siblings.count).to eq(1)
      expect(@b1[:gina].siblings).to include(@b1[:larry])
      expect(@b1[:mary].siblings.count).to eq(1)
      expect(@b1[:mary].siblings).to include(@b1[:john])
      expect(paul.siblings).to be_empty
    end

    it "#children?" do
      expect(@b1[:harry].children?).to be_true
      expect(@b1[:mary].children?).to be_false
    end

    it "#parent?" do
      expect(@b1[:harry].parent?).to be_false
      expect(@b1[:mary].parent?).to be_true
    end

  end
end