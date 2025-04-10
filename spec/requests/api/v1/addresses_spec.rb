require "rails_helper"
require_relative "../../../../app/services/address_csv_importer"

RSpec.describe "Api::V1::Addresses", type: :request do
  describe "GET /index" do
    let!(:address1) { FactoryBot.create(:address) }
    let!(:address2) { FactoryBot.create(:address) }
    let!(:address3) { FactoryBot.create(:address) }

    it "all successfully returns all addresses" do
      get "/api/v1/addresses"

      expect(response.status).to eq 200
      expect(response.body).to eq Address.all.to_json
    end
  end

  describe "POST /create" do
    before(:each) do
      allow_any_instance_of(AddressCSVImporter).to receive(:import).and_return(import_successful)
    end

    let(:import_successful) { true }
    let(:csv_file_name) { "addresses.csv" }

    context "unable to import CSV" do
      let(:import_successful) { false }

      it "does not create new Address records" do
        prev_address_count = Address.count

        post "/api/v1/addresses", params: { file: csv_file_name }

        expect(Address.count).to eq prev_address_count
        expect(response).to have_http_status(:error)
      end
    end

    it "successfully creates addresses from CSV" do
      post "/api/v1/addresses", params: { file: csv_file_name }

      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /update" do
    let!(:address) { FactoryBot.create(:address) }

    context "unable to find address" do
      it "does not update address" do
        old_address_zip = address.zip

        put "/api/v1/addresses/#{address.id + 42}", params: {address: {zip: "12345"}}

        expect(address.reload.zip).to eq old_address_zip
        expect(response.status).to eq 404
        expect(response.body).to eq({error: "Address not found"}.to_json)
      end
    end

    context "unable to update address" do
      before(:each) do
        allow_any_instance_of(Address).to receive(:update).and_return(false)
      end

      it "does not update address" do
        old_address_zip = address.zip

        put "/api/v1/addresses/#{address.id}", params: {address: {zip: "12345"}}

        expect(response.status).to eq 400
        expect(response.body).to include "Unable to update address:"
        expect(address.reload.zip).to eq old_address_zip
      end
    end

    it "updates successfully the address" do
      put "/api/v1/addresses/#{address.id}", params: {address: {zip: "12345"}}

      expect(response.status).to eq 200
      expect(response.body).to eq({message: "Address updated successfully"}.to_json)
      expect(address.reload.zip).to eq "12345"
    end
  end

  describe "DELETE /destroy" do
    let!(:address) { FactoryBot.create(:address) }

    context "unable to find address" do
      it "does not update address" do
        old_address_zip = address.zip

        delete "/api/v1/addresses/#{address.id + 42}"

        expect(address.reload.zip).to eq old_address_zip
        expect(response.status).to eq 404
        expect(response.body).to eq({error: "Address not found"}.to_json)
      end
    end

    context "unable to delete address" do
      before(:each) do
        allow_any_instance_of(Address).to receive(:destroy).and_return(false)
      end

      it "does not delete address" do
        delete "/api/v1/addresses/#{address.id}"

        expect(response.status).to eq 400
        expect(response.body).to include "Unable to destroy address:"
        expect(address.reload.id).to eq address.id
      end
    end

    it "destroys successfully the address" do
      existing_address_id = address.id

      delete "/api/v1/addresses/#{address.id}"

      expect(response.status).to eq 200
      expect(response.body).to eq({ message: "Address destroyed successfully" }.to_json)
      expect(Address.find_by(id: existing_address_id)).to be_nil
    end
  end
end
