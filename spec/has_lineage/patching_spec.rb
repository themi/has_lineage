require 'spec_helper'

class SampleClass
  include HasLineage
  def self.belongs_to(*args); end
  def self.has_many(*args); end
  def self.before_save(*args); end
end

describe SampleClass, "patching" do

  describe "class methods", "defined" do
    it { expect(described_class).to respond_to(:has_lineage) }
    it { expect(described_class).to_not respond_to(:root) }
  end

  describe "instance methods", "defined" do
    it { expect(described_class.new).to respond_to(:root) }
    it { expect(described_class.new).to_not respond_to(:has_lineage) }
  end

  describe "has_lineage_options" do
    let(:options) { {} }

    before { described_class.has_lineage options }

    context "using an instance" do
      it { expect(described_class.new.has_lineage_options[:parent_key]).to eq('parent_id') }

      context "with a custom field" do
        let(:options) { {parent_key: 'custom_id'} }
        it { expect(described_class.new.has_lineage_options[:parent_key]).to eq('custom_id') }
      end
    end

    context "using the class" do
      it { expect(described_class.has_lineage_options[:parent_key]).to eq('parent_id') }

      context "with a custom field" do
        let(:options) { {parent_key: 'custom_id'} }
        it { expect(described_class.has_lineage_options[:parent_key]).to eq('custom_id') }
      end
    end
  end

end