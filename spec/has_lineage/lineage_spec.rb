require 'spec_helper'
require 'database_helper'

class Post < ActiveRecord::Base
	has_lineage {}
end

describe Post do
	before { setup_db }
	after  { teardown_db }

	let!(:father) { Post.create(name: 'Jack') }

	it "do it" do
		father.name.should == 'Jack'
	end
end