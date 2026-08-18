require "dsp_analyzer"

class Api::V1::DiagnosticsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def upload_audio
    audio_param = params[:audio_file]
    sim_mode = params[:simulation_mode]
    turbine_serial = params[:turbine_serial] || "WT-RENEW-01"

    if audio_param.respond_to?(:path)
      file_stream = File.open(audio_param.path, "rb")
      snapshot = InMemoryDspService.process(file_stream, turbine_serial)
    else
      magnitudes = Array.new(100) { rand(3..8) }
      magnitudes[12] = 130 # Safe fundamental
      magnitudes[24] = 85  # Safe overtone
      magnitudes[36] = 55  # Safe overtone

      if sim_mode == "anomaly"
        magnitudes[43] = 190 # Inject non-synchronous fault to trigger C engine
      end

      c_metrics = ::DspAnalyzer.analyze(magnitudes)

      snapshot = AcousticSnapshot.create!(
        turbine_serial: turbine_serial,
        status: c_metrics[:status],
        detected_anomaly_hz: c_metrics[:flagged_hz],
        frequency_magnitudes: magnitudes
      )
    end

    render json: {
      turbine_health: snapshot.status == "healthy" ? "healthy" : "anomaly",
      flagged_frequency_hz: snapshot.detected_anomaly_hz || 0,
      frequency_magnitudes: snapshot.frequency_magnitudes
    }
  ensure
    file_stream.close if file_stream.respond_to?(:close)
  end
end
