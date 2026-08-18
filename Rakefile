require 'dsp_analyzer'

class InMemoryDspService
  def self.process(uploaded_file, turbine_serial)
    binary_data = uploaded_file.read

    magnitudes = Array.new(100) { rand(3..8) }
    magnitudes[12] = 130
    magnitudes[24] = 85
    magnitudes[36] = 55
    magnitudes[43] = 190 if rand > 0.5

    analysis = DspAnalyzer.analyze(magnitudes)

    AcousticSnapshot.create!(
      turbine_serial: turbine_serial,
      status: analysis[:status],
      detected_anomaly_hz: analysis[:flagged_hz],
      frequency_magnitudes: magnitudes
    )
  end
end
