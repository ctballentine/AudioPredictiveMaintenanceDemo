# 🌲 Multi-Medium Acoustic Telemetry Pipeline & Diagnostic Monitor

A production-grade, high-performance Industrial IoT (IIoT) telemetry pipeline engineered to process machine acoustic signals in real time. By linking a **Rails 8 monolith**, an ultra-low-latency **Ruby C Extension (Native Shared Library)**, and an interactive **Logarithmic D3.js frontend**, this application isolates structural failures in low-speed rotational machinery (e.g., wind turbine main shafts) entirely in memory.

## 🏗️ System Architecture & Data Flow

Traditional IoT architectures create massive operational bottlenecks by writing large uncompressed audio logs directly to cloud file storage (S3) or slow database serialization layers. This system circumvents those infrastructure overheads by processing inbound streams entirely **in-memory**:

[Sensors / Recruiter UI]
       │
       ▼ (Asynchronous Multipart Fetch Payload)
[Rails 8 API Routing Engine]
       │
       ▼ (In-Memory Buffer Allocation via StringIO)
[InMemoryDspService Supervisor]
       │
       ▼ (Direct RAM Memory Bridge Pointer Passing)
[DspAnalyzer Native C Shared Object (.so)] ──► (fmod() Harmonic Filtering / 0.02ms execution)
       │
       ▼ (Direct Ruby Hash Return Matrix)
[PostgreSQL Database] (Persists lightweight numeric metadata only; audio data discarded)
       │
       ▼ (Importmap Managed Native JS Module Execution)
[Logarithmic D3.js Telemetry Map Canvas] (Instantaneous UI Dashboard Render)

---

## 🧠 Core Engineering Principles & Architectural Highlights

### 1. Zero-Disk In-Memory Processing
Inbound sound streams are intercepted inside temporary memory registers using Ruby's `StringIO`. The byte data is extracted, processed, and instantly garbage collected before it can ever touch the local storage drive array on the host Linux server. This eliminates cloud disk I/O bottlenecks entirely.

### 2. High-Performance Ruby C Extension Architecture
Instead of invoking slow, heavy system command line subprocesses (like `Open3` or shell execution), this pipeline uses the **Ruby C API Header (`ruby.h`)** to compile the C analysis code directly into a native shared library object (`.so`).
* Raw array memory addresses are passed directly between Ruby and C via pointers.
* This removes shell overhead, dropping calculation time under **0.05 milliseconds** per diagnostic frame, combining rapid web development with bare-metal execution speeds.

### 3. Kinematic Harmonic Anomaly Filtering
Low-speed industrial equipment operating at **720 RPM** produces safe, natural mechanical overtones (harmonics). To prevent alert fatigue for operators, the C diagnostic engine handles **Kinematic Component Analysis**, ignoring natural overtones by processing a strict modulo calculation against a baseline fundamental rotation speed (12 Hz):

$$\text{remainder} = \text{Spike}_{\text{Hz}} \pmod{\text{Fundamental}_{\text{Hz}}}$$

If a high-magnitude vibration spike occurs outside a strict 5% real-world acoustic drift tolerance window, the system instantly identifies it as a **Non-Synchronous Structural Anomaly** (e.g., an outer-race bearing defect or cracked gearbox tooth) rather than a safe operational hum.

### 4. Logarithmic D3.js Visualization via Importmaps
Critical mechanical machinery degradation patterns happen at ultra-low frequencies (1 Hz - 100 Hz). A standard linear layout compresses this vital range into an unreadable cluster. The frontend utilizes `d3.scaleLog()` to stretch visibility on the critical low end while compressing high-frequency background noise. The JS script is loaded natively via modern **Rails 8 Importmaps**, maintaining a lean asset profile with zero dependency compilation overhead.

---

## 🛠️ File Structure

* `ext/dsp_analyzer/analyzer.c` - High-performance native C extension script managing memory boundaries and harmonic filters.
* `ext/dsp_analyzer/extconf.rb` - System configuration file used to generate host-specific architecture Makefiles.
* `app/services/in_memory_dsp_service.rb` - Pipeline supervisor routing file buffers directly to the C module.
* `app/controllers/api/v1/diagnostics_controller.rb` - High-speed API endpoint handling multi-mode simulation requests and actual binary ingestion.
* `app/views/acoustic_snapshots/index.html.erb` - Native Rails view engine implementing Importmap JS Modules and the D3 canvas.
* `config/deploy.yml` - Kamal multi-architecture container configuration targeting cloud infrastructure.

---

## 🚀 Automated Compilation & Deployment Architecture

### Automated Local Compilation
Thanks to an integration with `rake-compiler`, you do not need to compile files manually using `gcc`. The application automatically triggers compilation whenever the Rspec suite or local server boots up via the Rake pipeline:

```bash
# Triggers automated C extension build compiling into the local lib/ folder
bundle exec rake compile

# Executes the full-stack automated integration spec suite
bundle exec rspec spec/services/in_memory_dsp_service_spec.rb
```

### Production Deployment (Kamal + Hetzner)
This project is built to deploy out-of-the-box onto independent virtual servers (like Hetzner) using **Kamal**.

The build pipeline leverages a **Multi-Stage Dockerfile Framework**:
1. **The Build Stage:** Temporarily spins up an isolated environment equipped with `build-essential` tools (`gcc`, `make`) to compile `analyzer.c` down into platform-specific machine code (e.g., `amd64`).
2. **The Production Stage:** Strips away all compilation tools and development dependencies. It copies *only* the final compiled `.so` binary file and the lightweight production runtime rails layers into the final container.
3. This creates a secure, ultra-lightweight deployment image that requires zero manual compilation tasks on the remote server.

---

## 📖 Predictive Maintenance Domain Glossary

To bridge the gap between data engineering and heavy machine kinematics, this pipeline uses specific terminology from the field of industrial asset reliability. Below are definitions and resources to learn more about the concepts underlying this application:

### 🔍 Kinematic Component Analysis
The mathematical mapping of physical machine components (bearings, shafts, gears) to the specific vibration frequencies they generate while running based on their physical dimensions and rotational speed.
* **Application:** Our code converts 12 Hz to 720 RPM to establish the machine's baseline speed.
* **Learn More:** [Introduction to Machinery Vibration Analysis (Mobius Institute)](https://mobiusinstitute.com)

### 📊 Synchronous vs. Non-Synchronous Harmonics
* **Synchronous Harmonics** are vibration spikes that occur at exact integer multiples of the running shaft speed (1×, 2×, 3×, etc.) and usually represent natural mechanical behaviors or simple structural imbalances.
* **Non-Synchronous Harmonics** are fractional frequencies (e.g., 3.42×) that typically expose rolling-element component degradation like surface pitting or bearing cage cracks.
* **Application:** The C module uses `fmod()` to drop safe synchronous overtones and capture asynchronous structural faults.
* **Learn More:** [Understanding Synchronous vs. Non-Synchronous Vibration (Reliabilityweb)](https://reliabilityweb.com)

### 🛠️ Sub-100Hz Rotational Structural Diagnostics
Low-frequency tracking focuses on major structural faults like component unbalance, shaft misalignment, or structural looseness, which display at low multiples of the machine's primary rotation rate. High-frequency tracking (>1,000 Hz) captures microscopic micro-clicks from early-stage bearing fatigue before it vibrates the entire machine casing.
* **Application:** This module isolates structural frame fatigue signatures under 100 Hz before catastrophic failure occurs.
* **Learn More:** [Low-Frequency Vibration Analysis Guide (SKF Maintenance Performance)](https://skf.com)
