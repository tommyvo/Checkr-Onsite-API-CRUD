class CreateCsvFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :csv_files do |t|
      t.boolean :processed, default: false

      t.timestamps
    end
  end
end
