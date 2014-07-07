require 'spec_helper'
require 'database_helper'

describe Post, "Class methods" do
  before { setup_db }
  after  { teardown_db }

  describe "#has_lineage" do
    subject(:lineage_options) { described_class.has_lineage(options) }

    context "with a non-Hash argument" do
      let(:options) { ['parent_key_column'] }
      specify "raises a GeneralException" do
        expect{ lineage_options }.to raise_error(HasLineage::GeneralException, "Options for has_lineage must be in a hash.")
      end
    end

    context "with an unknown setting" do
      let(:options) { {random_setting: 'O'} }
      specify "raises ArgumentError" do
        expect{ lineage_options }.to raise_error(ArgumentError, "Unknown key: :random_setting. Valid keys are: :parent_key_column, :lineage_column, :leaf_width, :delimiter, :tree_key_column, :order_column, :counter_cache")
      end
    end

    context "with empty hash" do
      let(:options) { {} }
      specify "doesnot raise an error" do
        expect{ lineage_options }.to_not raise_error
      end
    end
  end

  describe ".has_lineage_options" do
    before { described_class.has_lineage(options) }

    context "with empty hash" do    
      let(:options) { {} }

      specify "sets default values" do
        expect(described_class.has_lineage_options[:parent_key_column]).to  eq 'parent_id'
        expect(described_class.has_lineage_options[:lineage_column]).to     eq 'lineage'
        expect(described_class.has_lineage_options[:leaf_width]).to         eq 4
        expect(described_class.has_lineage_options[:delimiter]).to          eq '/'
        expect(described_class.has_lineage_options[:tree_key_column]).to    eq nil
        expect(described_class.has_lineage_options[:order_column]).to       eq nil
        expect(described_class.has_lineage_options[:counter_cache]).to      eq false
      end
    end

    context "with custom settings" do
      let(:options) { {leaf_width: 6, counter_cache: true} }

      specify "sets custom and default values" do
        expect(described_class.has_lineage_options[:parent_key_column]).to  eq 'parent_id'
        expect(described_class.has_lineage_options[:lineage_column]).to     eq 'lineage'
        expect(described_class.has_lineage_options[:leaf_width]).to         eq 6
        expect(described_class.has_lineage_options[:delimiter]).to          eq '/'
        expect(described_class.has_lineage_options[:tree_key_column]).to    eq nil
        expect(described_class.has_lineage_options[:order_column]).to       eq nil
        expect(described_class.has_lineage_options[:counter_cache]).to      eq true
      end
    end

  end

  describe "#new_lineage_path" do
    before { described_class.has_lineage }

    context "with no prefix and index=0" do
      let(:prefix)   { nil }
      let(:index)   { 0 }
      specify { expect(described_class.new_lineage_path(prefix, index)).to eq('/0001') }
    end

    context "with prefix=PREFIX and index=2" do
      let(:prefix)   { "PREFIX" }
      let(:index)   { 2 }
      specify { expect(described_class.new_lineage_path(prefix, index)).to eq('PREFIX/0003') }
    end
  end

end