#!/bin/bash
#
# Voice Support Installation Script
# Installs Whisper.cpp for transcription + configures Edge TTS for Telegram voice notes
# Tested on: Ubuntu 24.04 ARM64
# Estimated time: 10-15 minutes
#

set -e  # Exit on error

echo "================================================"
echo "OpenClaw Voice Support Installer"
echo "================================================"
echo ""
echo "This will install:"
echo "  - Whisper.cpp (voice transcription)"
echo "  - Edge TTS configuration (voice output)"
echo ""
echo "Estimated time: 10-15 minutes"
echo "Disk space required: ~200 MB"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please do not run this script as root"
   exit 1
fi

# Step 1: Install system dependencies
echo "📦 Step 1/6: Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y cmake build-essential git ffmpeg >/dev/null 2>&1
echo "✅ Dependencies installed"
echo ""

# Step 2: Create tools directory
echo "📁 Step 2/6: Creating tools directory..."
mkdir -p ~/.openclaw/tools
cd ~/.openclaw/tools
echo "✅ Directory created"
echo ""

# Step 3: Clone and build Whisper.cpp
echo "🔨 Step 3/6: Building Whisper.cpp (this may take 3-5 minutes)..."
if [ -d "whisper.cpp" ]; then
    echo "   Whisper.cpp already exists, updating..."
    cd whisper.cpp
    git pull -q
else
    git clone -q https://github.com/ggerganov/whisper.cpp.git
    cd whisper.cpp
fi

make -j$(nproc) >/dev/null 2>&1
echo "✅ Whisper.cpp built successfully"
echo ""

# Step 4: Download Whisper model
echo "📥 Step 4/6: Downloading Whisper base.en model (~142 MB)..."
if [ -f "models/ggml-base.en.bin" ]; then
    echo "   Model already exists, skipping download"
else
    bash ./models/download-ggml-model.sh base.en >/dev/null 2>&1
fi
echo "✅ Model downloaded"
echo ""

# Step 5: Create helper script
echo "📝 Step 5/6: Creating transcription helper script..."
cat > ~/.openclaw/tools/whisper-transcribe.sh << 'SCRIPT_EOF'
#!/bin/bash
# Whisper transcription helper for OpenClaw
INPUT_FILE="$1"
WAV_FILE="/tmp/whisper_$(date +%s).wav"
WHISPER_BIN="$HOME/.openclaw/tools/whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="$HOME/.openclaw/tools/whisper.cpp/models/ggml-base.en.bin"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <audio_file>"
    exit 1
fi

ffmpeg -i "$INPUT_FILE" -ar 16000 -ac 1 -f wav "$WAV_FILE" -y 2>/dev/null
$WHISPER_BIN -m $WHISPER_MODEL -f "$WAV_FILE" -nt 2>&1 | \
    grep '\[00:00:' | sed 's/\[.*\]//' | sed 's/^[[:space:]]*//'
rm -f "$WAV_FILE"
SCRIPT_EOF

chmod +x ~/.openclaw/tools/whisper-transcribe.sh
echo "✅ Helper script created"
echo ""

# Step 6: Configure OpenClaw for Edge TTS
echo "⚙️  Step 6/6: Configuring OpenClaw for Telegram voice notes..."

# Check if openclaw command exists
if ! command -v openclaw &> /dev/null; then
    echo "⚠️  Warning: openclaw command not found. Skipping configuration."
    echo "   Please configure Edge TTS manually after installation."
else
    # Apply Edge TTS configuration
    openclaw gateway config.patch << 'CONFIG_EOF'
{
  "messages": {
    "tts": {
      "auto": "always",
      "provider": "edge",
      "edge": {
        "enabled": true,
        "voice": "en-US-MichelleNeural",
        "lang": "en-US",
        "outputFormat": "audio-24khz-48kbitrate-mono-opus"
      }
    }
  }
}
CONFIG_EOF

    echo "✅ OpenClaw configured"
    echo ""
    
    # Restart gateway
    echo "🔄 Restarting OpenClaw gateway..."
    openclaw gateway restart
    echo "✅ Gateway restarted"
fi

echo ""
echo "================================================"
echo "✅ Voice Support Installation Complete!"
echo "================================================"
echo ""
echo "What was installed:"
echo "  📍 Whisper.cpp: ~/.openclaw/tools/whisper.cpp"
echo "  📍 Model: ~/.openclaw/tools/whisper.cpp/models/ggml-base.en.bin"
echo "  📍 Helper: ~/.openclaw/tools/whisper-transcribe.sh"
echo ""
echo "Configuration applied:"
echo "  🎤 Transcription: Whisper.cpp (local, fast, accurate)"
echo "  🔊 Voice output: Edge TTS (Microsoft Neural, free)"
echo "  📱 Format: Opus (proper Telegram voice notes with waveforms)"
echo ""
echo "Next steps:"
echo "  1. Send a voice message to your OpenClaw bot"
echo "  2. You should receive a voice note reply (not an audio file)"
echo "  3. Check for blue waveform interface in Telegram"
echo ""
echo "Performance:"
echo "  • Transcription: ~20x faster than real-time"
echo "  • Voice generation: ~2-3 seconds per response"
echo "  • Total round-trip: ~8-13 seconds"
echo ""
echo "Troubleshooting:"
echo "  • If no voice replies: Check openclaw config get | grep tts"
echo "  • If wrong format: Verify outputFormat is 'audio-24khz-48kbitrate-mono-opus'"
echo "  • Test transcription: ~/.openclaw/tools/whisper-transcribe.sh test.ogg"
echo ""
echo "Enjoy your voice-enabled OpenClaw! 🎉"
echo ""
