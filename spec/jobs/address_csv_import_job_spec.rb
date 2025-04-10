require "rails_helper"

RSpec.describe AddressCsvImportJob, type: :job do
  include ActiveJob::TestHelper

  let(:csv_file_record) { CsvFile.create }
  let(:csv_blob) do
    fixture_file_upload(Rails.root.join("spec/fixtures/files/addresses.csv"), "text/csv")
  end

  before do
    csv_file_record.csv_file.attach(csv_blob)
  end

  it "calls AddressCsvImporter with the CSV file path" do
    expect(AddressCsvImporter).to receive(:new).and_call_original

    perform_enqueued_jobs do
      described_class.perform_later(csv_file_record.id)
    end
  end
end
