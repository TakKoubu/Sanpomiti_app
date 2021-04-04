class CreateSpots < ActiveRecord::Migration[5.2]
  def change
    create_table :spots do |t|
      t.references :walkcourse, foreign_key: true
      t.string :name
      t.time :transit_time, default: nil
      t.time :time_required, default: nil
      t.string :address
      t.text :description

      t.timestamps
    end
  end
end
