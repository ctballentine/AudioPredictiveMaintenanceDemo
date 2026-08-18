require 'rails_helper'
require 'dsp_analyzer'

RSpec.describe InMemoryDspService, type: :service do
  let(:turbine_serial) { "WT-SPEC-TEST" }
  let(:mock_magnitudes) { Array.new(100) { rand(3..8) } }
  let(:mock_file) { instance_double(File, read: mock_magnitudes) }

  describe ".process" do
    context "when running telemetry checks via the native C extension" do
      it "routes the array through the C engine and invokes model persistence parameters" do
        # Stub out the underlying active C extension response values natively
        expect(DspAnalyzer).to receive(:analyze).with(mock_magnitudes).and_return({
          status: "healthy",
          flagged_hz: nil
        })

        # Verify that the AcousticSnapshot creation interface receives accurate arguments
        expect(AcousticSnapshot).to receive(:create!).with(
          turbine_serial: turbine_serial,
          status: "healthy",
          detected_anomaly_hz: nil,
          frequency_magnitudes: mock_magnitudes
        )

        InMemoryDspService.process(mock_file, turbine_serial)
      end
    end
  end
end
