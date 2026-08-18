class CreateAcousticSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :acoustic_snapshots do |t|
      t.string :turbine_serial, null: false, index: true
      t.float :detected_anomaly_hz
      t.string :status, default: "healthy"
      t.jsonb :frequency_magnitudes, default: []

      t.timestamps
    end
  end
end
