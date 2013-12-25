require 'spec_helper'
require 'database_helper'

describe Post do
	before do 
		setup_db 
  	described_class.has_lineage
	end
	after  { teardown_db }

	context "with root node" do
	  subject(:harry) { Post.create(:name => 'Harry') }

	  its(:name) 		{ should eq('Harry') }
	  its(:lineage) { should be_nil }

	  context "build the tree structure" do
	  	# before { subject.reset_tree }
		  # its(:lineage) { should_not be_nil }
		end
	end
end