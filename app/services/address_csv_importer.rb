class AddressCSVImporter
  attr_reader :csv_file

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def import
    opened_file = File.open(csv_file)

    ActiveRecord::Base.transaction do
      CSV.foreach(opened_file, headers: true) do |row|
        process_csv(row)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
      return false
    end

    true
  end

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
