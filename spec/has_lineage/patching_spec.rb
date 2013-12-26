require 'spec_helper'

class SampleClass
  include HasLineage
  def self.belongs_to(*args); end
  def self.has_many(*args); end
end

describe SampleClass, "patching" do

  describe "class methods", "defined" do
    it { described_class.should respond_to(:has_lineage) }
    it { described_class.should_not respond_to(:root) }
  end

  describe "instance methods", "defined" do
    subject { described_class.new }
    it { subject.should respond_to(:root) }
    it { subject.should_not respond_to(:has_lineage) }
  end

  describe "has_lineage_options" do
    let(:options) { {} }

    before { described_class.has_lineage options }

    context "using an instance" do
      it { described_class.new.has_lineage_options[:parent_key].should == 'parent_id' }

      context "with a custom field" do
        let(:options) { {parent_key: 'custom_id'} }
        it { described_class.new.has_lineage_options[:parent_key].should == 'custom_id' }
      end
    end

    context "using the class" do
      it { described_class.has_lineage_options[:parent_key].should == 'parent_id' }

      context "with a custom field" do
        let(:options) { {parent_key: 'custom_id'} }
        it { described_class.has_lineage_options[:parent_key].should == 'custom_id' }
      end
    end
  end

end