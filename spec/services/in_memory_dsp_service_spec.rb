require 'rails_helper'
require 'dsp_analyzer'

RSpec.describe InMemoryDspService, type: :service do
  let(:turbine_serial) { "WT-SPEC-TEST" }

  def create_mock_upload(magnitude_array)
    instance_double(File, read: magnitude_array)
  end

  describe ".process" do
    context "when processing a healthy structural machinery data profile" do
      let(:healthy_magnitudes) do
        arr = Array.new(100) { rand(3..8) }
        arr[12] = 130
        arr[24] = 85
        arr[36] = 55
        arr
      end

      it "communicates with the compiled C binary and persists a healthy snapshot to Postgres" do
        mock_file = create_mock_upload(healthy_magnitudes)

        expect {
          InMemoryDspService.process(mock_file, turbine_serial)
        }.to change(AcousticSnapshot, :count).by(1)

        snapshot = AcousticSnapshot.last
        expect(snapshot.turbine_serial).to eq(turbine_serial)
        expect(snapshot.status).to eq("healthy")
        expect(snapshot.detected_anomaly_hz).to be_nil
        expect(snapshot.frequency_magnitudes.length).to eq(100)
      end
    end

    context "when an unnatural non-synchronous vibration is injected" do
      let(:faulty_magnitudes) do
        arr = Array.new(100) { rand(3..8) }
        arr[12] = 130
        arr[43] = 190
        arr
      end

      it "accurately routes the array to the C library and isolates the critical anomaly" do
        mock_file = create_mock_upload(faulty_magnitudes)

        InMemoryDspService.process(mock_file, turbine_serial)

        snapshot = AcousticSnapshot.last
        expect(snapshot.status).to eq("critical_anomaly")
        expect(snapshot.detected_anomaly_hz).to eq(43)
      end
    end
  end
end
