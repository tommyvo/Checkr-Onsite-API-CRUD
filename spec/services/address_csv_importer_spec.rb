require "rails_helper"
require_relative "../../app/services/address_csv_importer"

RSpec.describe AddressCSVImporter do
  describe "#import" do
    let(:csv_text) do
      <<~CSV
        Street Address,Secondary Address,City,State,Zip code
        One Montgomery Street,Suite 2400,San Francisco,CA,94104
      CSV
    end

    let(:csv_text_file) do
      Tempfile.new('csv').tap do |file|
        file << csv_text
        file.rewind
      end
    end

    after do
      csv_text_file.unlink
    end

    subject { AddressCSVImporter.new(csv_text_file.path).import }

    context "Unable to save address" do
      before(:each) do
        allow(Address).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "logs an error" do
        allow(Rails.logger).to receive(:error)

        subject

        expect(Rails.logger).to have_received(:error).with(anything)
      end

      it "does not change DB" do
        expect { subject }.to change(Address, :count).by(0)
      end

      it "returns false" do
        expect(subject).to eq false
      end
    end

    it "adds the addresses" do
      expect { subject }.to change(Address, :count).by(1)

      last_address = Address.last

      expect(last_address.street_address).to eq("One Montgomery Street")
      expect(last_address.secondary_address).to eq("Suite 2400")
      expect(last_address.city).to eq("San Francisco")
      expect(last_address.state).to eq("CA")
      expect(last_address.zip).to eq("94104")
    end

    it "returns true" do
      expect(subject).to eq(true)
    end
  end
end
