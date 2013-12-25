require 'spec_helper'
require 'database_helper'

describe Post do
	before { setup_db ; described_class.has_lineage }
	after  { teardown_db }

	context "with root node" do
	  let!(:harry) { described_class.create(:name => 'Harry') }

	  it "lineage path initially unset" do
	  	harry.lineage.should be_nil
	  end

	  context "when reset_lineage_tree" do
	  	before do
		  	described_class.reset_lineage_tree
		  	harry.reload
	  	end

		  it "lineage path is set" do
		  	harry.lineage.should eq("/0001")
			end
		end
	end

	context "with a root node and 2 children" do
	  let(:harry) { described_class.create(:name => 'Harry') }
		let(:mary) { described_class.create(:name => 'Mary') }
		let(:john) { described_class.create(:name => 'John') }

  	before do
	  	described_class.reset_lineage_tree do
	  		harry.lineage_children << mary
	  		harry.lineage_children << john
	  	end
  	end

  	it { harry.lineage_children.count.should == 2 }

  	it "sets root lineage path to 0001" do
  		harry.reload
  		harry.lineage_path.should == "/0001" 
  	end

  	it "sets 1st child lineage path to 0001/0001" do
  		mary.reload
  		mary.lineage_path.should == "/0001/0001"
  	end

  	it "sets 2nd child lineage path to 0001/0002" do
  		john.reload
  		john.lineage_path.should == "/0001/0002"
  	end
	end
end