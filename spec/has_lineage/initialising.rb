require 'spec_helper'

class SampleClass
	include HasLineage
end

describe SampleClass do

	it { should respond_to(:has_lineage) }

	context "methods" do
	  subject { SomeClass.new }

	  it 'has something to' do
	  	subject.should respond_to(:nothing)
	  end
	end

end