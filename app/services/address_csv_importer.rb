class AddressCsvImporter < BaseCsvImporter
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
