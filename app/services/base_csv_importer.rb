class BaseCsvImporter
  attr_reader :csv_file

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def import
    ActiveRecord::Base.transaction do
      File.open(csv_file) do |opened_file|
        CSV.foreach(opened_file, headers: true) do |row|
          process_csv(row)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
      return false
    end

    true
  end

  private

  def process_csv(row)
    raise NotImplementedError
  end
end
