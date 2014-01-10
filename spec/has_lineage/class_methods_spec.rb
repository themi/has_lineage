require 'spec_helper'
require 'database_helper'

describe Post, "Class methods" do
  before { setup_db }
  after  { teardown_db }

  describe "#has_lineage" do
    context "with a non-Hash argument" do
      let(:options) { ['parent_key_column'] }
      it "raises a GeneralException" do
        expect{ described_class.has_lineage(options) }.to raise_error(HasLineage::GeneralException, "Options for has_lineage must be in a hash.")
      end
    end

    context "with an unknown setting" do
      let(:options) { {random_setting: 'O'} }
      it "raises ArgumentError" do
        expect{ described_class.has_lineage(options) }.to raise_error(ArgumentError, "Unknown key: random_setting")
      end
    end

    context "with empty hash" do
      let(:options) { {} }
      it "doesnot raise an error" do
        expect{ described_class.has_lineage(options) }.to_not raise_error
      end
    end
  end

  describe ".has_lineage_options" do
    before { described_class.has_lineage(options) }

    context "with empty hash" do    
      let(:options) { {} }

      it "sets default values" do
        described_class.has_lineage_options[:parent_key_column].should     == 'parent_id'
        described_class.has_lineage_options[:lineage_column].should == 'lineage'
        described_class.has_lineage_options[:leaf_width].should     == 4
        described_class.has_lineage_options[:delimiter].should      == '/'
        described_class.has_lineage_options[:tree_key_column].should     be_nil
        described_class.has_lineage_options[:order].should          be_nil
        described_class.has_lineage_options[:counter_cache].should  be_false
      end
    end

    context "with custom settings" do
      let(:options) { {leaf_width: 6, counter_cache: true} }

      it "sets custom and default values" do
        described_class.has_lineage_options[:parent_key_column].should     == 'parent_id'
        described_class.has_lineage_options[:lineage_column].should == 'lineage'
        described_class.has_lineage_options[:leaf_width].should     == 6
        described_class.has_lineage_options[:delimiter].should      == '/'
        described_class.has_lineage_options[:tree_key_column].should     be_nil
        described_class.has_lineage_options[:order].should          be_nil
        described_class.has_lineage_options[:counter_cache].should  be_true
      end
    end

  end

  describe "#new_lineage_path" do
    before { described_class.has_lineage }

    context "with no prefix and index=0" do
      let(:prefix)   { nil }
      let(:index)   { 0 }
      it { expect(described_class.new_lineage_path(prefix, index)).to eq('/0001') }
    end

    context "with prefix=PREFIX and index=2" do
      let(:prefix)   { "PREFIX" }
      let(:index)   { 2 }
      it { expect(described_class.new_lineage_path(prefix, index)).to eq('PREFIX/0003') }
    end
  end

end