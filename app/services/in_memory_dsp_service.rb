class InMemoryDspService
  def self.process(uploaded_file, turbine_serial)
    magnitude_array = uploaded_file.read

    c_metrics = ::DspAnalyzer.analyze(magnitude_array)

    AcousticSnapshot.create!(
      turbine_serial: turbine_serial,
      status: c_metrics[:status],
      detected_anomaly_hz: c_metrics[:flagged_hz],
      frequency_magnitudes: magnitude_array || []
    )
  end
end
