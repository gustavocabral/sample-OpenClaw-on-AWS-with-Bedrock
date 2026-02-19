# OpenClaw Enhancements

Optional features you can add to your OpenClaw deployment after the base system is running.

## Available Enhancements

### 🎤 Voice Support for Telegram

Enable natural voice conversations with your OpenClaw assistant.

**Features:**
- High-quality voice transcription (Whisper.cpp)
- Natural voice replies (Microsoft Edge TTS)
- Proper Telegram voice notes with waveforms
- ~20x faster than real-time transcription

**Installation time:** 10-15 minutes  
**Disk space:** ~200 MB  
**Cost:** Free

**Install via assistant:**
```
"Install voice support"
```

**Manual installation:**
```bash
bash enhancements/install-voice.sh
```

📖 [Full Documentation](VOICE-TELEGRAM.md)

---

### 🌐 Browser Automation

Add web browsing, screenshots, and automation capabilities.

**Features:**
- Open and navigate websites
- Take screenshots
- Extract content from pages
- Fill forms and interact with elements
- Handle JavaScript-heavy sites

**Installation time:** 5-10 minutes  
**Disk space:** ~180 MB  
**Cost:** Free

**Install via assistant:**
```
"Install browser automation"
```

**Manual installation:**
```bash
bash enhancements/install-browser.sh
```

📖 [Full Documentation](BROWSER-AUTOMATION.md)

---

## Installation Methods

### Method 1: Via Chat (Recommended)

After deploying your OpenClaw instance, simply ask your assistant:

```
"Install voice support"
```

or

```
"Install browser automation"
```

The assistant will fetch and run the installation scripts automatically.

### Method 2: Manual Installation

SSH into your OpenClaw instance and run:

```bash
# Clone this repository (if not already present)
git clone https://github.com/aws-samples/sample-OpenClaw-on-AWS-with-Bedrock.git
cd sample-OpenClaw-on-AWS-with-Bedrock

# Install voice support
bash enhancements/install-voice.sh

# Install browser automation
bash enhancements/install-browser.sh
```

## Requirements

- Base OpenClaw deployment complete (via CloudFormation)
- Ubuntu 24.04 LTS (ARM64 or x86_64)
- Internet connection for downloads
- ~500 MB free disk space (for both enhancements)

## Testing

### Voice Support
Send a voice message to your Telegram bot. You should receive a voice note reply (not an audio file) with a blue waveform interface.

### Browser Automation
Ask your assistant: "Take a screenshot of example.com"

You should receive a screenshot image via Telegram.

## Troubleshooting

### Voice Support Issues

**No voice replies:**
```bash
openclaw config get | grep tts
# Verify provider is "edge" and outputFormat is "audio-24khz-48kbitrate-mono-opus"
```

**Audio file instead of voice note:**
Check that `outputFormat` is set to Opus (not MP3).

**Transcription errors or garbled text:**
The base OpenClaw uses sherpa-onnx which has lower accuracy. Install this voice enhancement to get Whisper.cpp, which provides much better transcription quality (especially for technical terms, names, and accents).

### Browser Automation Issues

**Browser timeout:**
```bash
openclaw config get | grep browser
# Verify executablePath points to Playwright Chromium
```

**Pages don't load:**
- Check internet connection
- Verify Chromium can run: `~/.cache/ms-playwright/chromium-1208/chrome-linux/chrome --version`

## Architecture

These enhancements integrate with OpenClaw's existing architecture:

```
┌─────────────────────────────────────────────────────────┐
│                    OpenClaw Gateway                      │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   Bedrock   │  │ Voice Module │  │    Browser    │  │
│  │   (Claude)  │  │  (Whisper +  │  │  (Playwright) │  │
│  │             │  │   Edge TTS)  │  │               │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
│                                                          │
└────────────────────────┬─────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │ Telegram│
                    └─────────┘
```

## Cost Impact

Both enhancements are **completely free**:

- **Whisper.cpp:** Local transcription, no API costs
- **Edge TTS:** Free Microsoft service, no API key required
- **Playwright:** Open source, no license fees

The only cost is EC2 compute, which remains the same. Both enhancements run efficiently on ARM64 Graviton instances.

## Performance Impact

**Voice Support:**
- Transcription: ~3-4 seconds for 10-second audio
- Voice generation: ~2-3 seconds
- Total round-trip: ~8-13 seconds
- Negligible CPU impact (Whisper is very efficient)

**Browser Automation:**
- Page load: 3-10 seconds typical
- Screenshot: 1-2 seconds
- Memory: ~200-300 MB per browser instance
- CPU: Moderate when active, idle otherwise

Both run efficiently on t4g.medium (2 vCPU, 4 GB RAM).

## Security Considerations

**Voice Support:**
- ✅ Transcription is local (Whisper.cpp)
- ⚠️ Edge TTS sends text to Microsoft servers
- ✅ No audio stored after transcription
- ✅ All processing on your EC2 instance

**Browser Automation:**
- ✅ Runs in isolated headless mode
- ✅ No sandbox (required for server environment, security via isolation)
- ⚠️ Browser can access public internet
- ✅ No data leaves your instance except for web requests

## Compatibility

| Enhancement | ARM64 | x86_64 | macOS |
|-------------|-------|--------|-------|
| Voice Support | ✅ | ✅ | ✅ |
| Browser Automation | ✅ | ✅ | ✅ |

All enhancements are tested on Ubuntu 24.04 LTS (ARM64 Graviton).

## Contributing

Found a bug or have an improvement? Please open an issue or pull request!

## License

These enhancements are provided under the same MIT license as the base project.

---

**Questions?** See individual enhancement documentation or open an issue.
