class AcousticSnapshot < ApplicationRecord
  validates :turbine_serial, presence: true
  validates :status, presence: true, inclusion: { in: %w[healthy critical_anomaly] }

  scope :critical, -> { where(status: "critical_anomaly") }
  scope :healthy, -> { where(status: "healthy") }
  scope :recent, -> { order(created_at: :desc) }

  def anomaly?
    status == "critical_anomaly"
  end

  def peak_frequency_hz
    (frequency_magnitudes || []).each_with_index.max&.last
  end
end
