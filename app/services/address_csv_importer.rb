require_relative "base_csv_importer"

class AddressCSVImporter < BaseCSVImporter
  private

  def process_csv(row)
    Address.create!(
      street_address: row["Street Address"],
      secondary_address: row["Secondary Address"],
      city: row["City"],
      state: row["State"],
      zip: row["Zip code"]
    )
  end
end
