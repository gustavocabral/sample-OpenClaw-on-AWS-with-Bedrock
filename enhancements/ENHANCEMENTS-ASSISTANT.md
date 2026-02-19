# Enhancement Installation Guide for OpenClaw Assistants

**This file helps OpenClaw assistants install optional features via chat commands.**

## Available Enhancements

### 1. Voice Support for Telegram
**User request examples:**
- "Install voice support"
- "Set up voice transcription"
- "Enable voice for Telegram"
- "Add Whisper transcription"

**Installation command:**
```bash
cd /tmp && \
git clone https://github.com/aws-samples/sample-OpenClaw-on-AWS-with-Bedrock.git openclaw-enhancements 2>/dev/null || (cd openclaw-enhancements && git pull) && \
bash openclaw-enhancements/enhancements/install-voice.sh
```

**What it does:**
- Installs Whisper.cpp for voice transcription (~142 MB model)
- Configures Edge TTS for voice output
- Sets up proper Telegram voice note format (Opus)
- Takes 10-15 minutes
- No user interaction required (fully automated)

**Verification:**
Ask user to send a voice message and verify they receive a voice note reply with waveform.

---

### 2. Browser Automation
**User request examples:**
- "Install browser automation"
- "Set up browser"
- "Add web scraping"
- "Enable screenshots"

**Installation command:**
```bash
cd /tmp && \
git clone https://github.com/aws-samples/sample-OpenClaw-on-AWS-with-Bedrock.git openclaw-enhancements 2>/dev/null || (cd openclaw-enhancements && git pull) && \
bash openclaw-enhancements/enhancements/install-browser.sh
```

**What it does:**
- Installs Playwright Chromium (~180 MB)
- Configures OpenClaw browser settings
- Enables headless mode for server environment
- Takes 5-10 minutes
- No user interaction required (fully automated)

**Verification:**
Take a screenshot of example.com and send it to the user.

---

## Assistant Instructions

When a user requests one of these enhancements:

1. **Acknowledge the request:**
   "I'll install voice support for you. This will take about 10-15 minutes. I'll let you know when it's done!"

2. **Run the installation command:**
   Execute the appropriate bash command above.

3. **Monitor progress:**
   The script will show progress messages. You can relay key milestones to the user.

4. **Verify installation:**
   After completion, test the feature and report success.

5. **Provide next steps:**
   Tell the user how to test the new feature.

## Example Interaction

**User:** "Install voice support"

**Assistant:** "I'll install voice support for you! This includes Whisper.cpp for transcription and Edge TTS for voice replies. It'll take about 10-15 minutes. I'll update you as it progresses..."

[Run installation command]

**Assistant:** "✅ Voice support installed successfully! The setup includes:
- Whisper.cpp transcription (20x faster than real-time)
- Edge TTS with Microsoft's Michelle Neural voice
- Proper Telegram voice notes with waveforms

Try it out: Send me a voice message and you'll get a voice note reply!"

## Troubleshooting

If installation fails:

1. **Check prerequisites:**
   - Base OpenClaw deployment complete
   - Internet connection available
   - Sufficient disk space (~500 MB free)

2. **Check logs:**
   The installation scripts provide detailed error messages.

3. **Manual verification:**
   ```bash
   # Voice support
   ls ~/.openclaw/tools/whisper.cpp/build/bin/whisper-cli
   openclaw config get | grep tts
   
   # Browser automation
   ls ~/.cache/ms-playwright/chromium-1208/chrome-linux/chrome
   openclaw config get | grep browser
   ```

## Notes for Assistants

- These scripts are **idempotent** (safe to run multiple times)
- All installations are **fully automated** (no user interaction needed)
- Scripts include **detailed progress output**
- Installations **automatically restart** OpenClaw gateway
- Both features are **free** (no API costs)
- Compatible with **ARM64 and x86_64** Ubuntu

## Repository Structure

```
sample-OpenClaw-on-AWS-with-Bedrock/
├── enhancements/
│   ├── README.md                    (User-facing overview)
│   ├── ENHANCEMENTS-ASSISTANT.md    (This file - assistant guide)
│   ├── install-voice.sh             (Voice installation script)
│   ├── install-browser.sh           (Browser installation script)
│   ├── VOICE-TELEGRAM.md            (Detailed voice documentation)
│   └── BROWSER-AUTOMATION.md        (Detailed browser documentation)
```

---

**For human users:** See [README.md](README.md) for user-facing documentation.
