require 'spec_helper'

class SomeClass
	include HasLineage
end

describe "HasLineage", "instantiation" do
  subject { SomeClass.new }

  it 'has something to' do
  	subject.should respond_to(:nothing)
  end

end