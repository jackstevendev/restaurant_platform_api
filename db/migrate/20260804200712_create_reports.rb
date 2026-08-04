class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports, id: :uuid do |t|
      t.string :status, null: false, default: 'pending'
      t.string :file_url

      t.timestamps
    end
  end
end
