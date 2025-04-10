class AddressCsvImportJob < ApplicationJob
  queue_as :default

  def perform(csv_file_id)
    csv_file = CsvFile.find(csv_file_id)
    blob = csv_file.csv_file.blob

    # Use an in-memory tempfile regardless of storage type
    file = Tempfile.new(["import", ".csv"])
    file.binmode
    file.write(blob.download)
    file.rewind

    importer = AddressCsvImporter.new(file.path)
    importer.import
  ensure
    file.close
    file.unlink
  end
end
