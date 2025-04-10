require "rails_helper"

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
    let(:import_successful) { true }
    let(:csv_file) do
      fixture_file_upload(Rails.root.join("spec/fixtures/files/addresses.csv"), "text/csv")
    end

    context "unable to import CSV" do
      let(:import_successful) { false }

      it "enqueues the import job" do
        ActiveJob::Base.queue_adapter = :test

        expect {
          post "/api/v1/addresses", params: { file: csv_file }
        }.to have_enqueued_job(AddressCsvImportJob)
      end
    end

    it "successfully creates addresses from CSV" do
      post "/api/v1/addresses", params: { file: csv_file }

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
