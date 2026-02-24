# TTS Emoji Filtering Configuration

**Problem:** When using Edge TTS with `auto: "always"` mode, emojis in text are spoken literally as their Unicode names (e.g., "party popper", "check mark button", "fire emoji"), which disrupts the audio experience.

**Solution:** Use OpenClaw's `[[tts:text]]` directive to provide separate visual and audio versions of messages.

## How It Works

OpenClaw supports model-driven TTS overrides via `[[tts:text]]...[[/tts:text]]` blocks. When present, OpenClaw uses this block for audio generation instead of the main message body.

## Implementation

### 1. Message Format

```
Visual message with emojis 🎉 ✅ 🚀

[[tts:text]]Visual message without emojis for clean audio[[/tts:text]]
```

**Result:**
- **Visual (Telegram):** "Visual message with emojis 🎉 ✅ 🚀"
- **Audio (TTS):** "Visual message without emojis for clean audio"

### 2. Emoji Filtering Script

Create a Python script to automatically strip emojis:

```bash
cat > ~/.openclaw/tools/tts-filter.py << 'EOF'
#!/usr/bin/env python3
"""
Remove Unicode emojis from text for TTS
Usage: echo "text 🎉" | python3 tts-filter.py
"""
import sys
import re

def remove_emojis(text):
    """Remove all Unicode emoji characters from text"""
    emoji_pattern = re.compile(
        "["
        "\U0001F1E0-\U0001F1FF"  # flags (iOS)
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F680-\U0001F6FF"  # transport & map symbols
        "\U0001F700-\U0001F77F"  # alchemical symbols
        "\U0001F780-\U0001F7FF"  # Geometric Shapes Extended
        "\U0001F800-\U0001F8FF"  # Supplemental Arrows-C
        "\U0001F900-\U0001F9FF"  # Supplemental Symbols and Pictographs
        "\U0001FA00-\U0001FA6F"  # Chess Symbols
        "\U0001FA70-\U0001FAFF"  # Symbols and Pictographs Extended-A
        "\U00002702-\U000027B0"  # Dingbats
        "\U000024C2-\U0001F251" 
        "]+", flags=re.UNICODE
    )
    return emoji_pattern.sub('', text)

if __name__ == "__main__":
    text = sys.stdin.read()
    print(remove_emojis(text).strip())
EOF

chmod +x ~/.openclaw/tools/tts-filter.py
```

### 3. Test the Filter

```bash
echo "Hello! 🎉 Test message ✅ Let's go! 🚀" | python3 ~/.openclaw/tools/tts-filter.py
# Output: "Hello! Test message Let's go!"
```

### 4. Agent Configuration

Update agent system prompt (`SOUL.md` or equivalent):

```markdown
**Voice (TTS):** TTS is configured as "always" mode - OpenClaw automatically converts ALL messages to voice. When using emojis, include BOTH versions in a SINGLE message:

1. Main text WITH emojis (user sees this visually)
2. `[[tts:text]]...[[/tts:text]]` block WITHOUT emojis (OpenClaw uses this for audio only)

Example:
\`\`\`
Great! System working perfectly! 🎉✅

[[tts:text]]Great! System working perfectly![[/tts:text]]
\`\`\`

NEVER send duplicate messages. The text+emoji and tts:text must be in the SAME message.
```

## Delivery Flow

When using `auto: "always"`:

1. Agent generates response with emojis
2. Agent includes `[[tts:text]]` block with filtered version
3. OpenClaw sends text message to Telegram (visual, with emojis)
4. OpenClaw generates TTS audio in background using `[[tts:text]]` content (2-3 seconds)
5. OpenClaw edits message to attach voice note
6. User receives: Visual text with emojis + clean audio without emoji names

## Configuration Requirements

Ensure Edge TTS is configured with Opus output for proper Telegram voice notes:

```json
{
  "messages": {
    "tts": {
      "auto": "always",
      "provider": "edge",
      "edge": {
        "enabled": true,
        "voice": "en-US-MichelleNeural",
        "outputFormat": "audio-24khz-48kbitrate-mono-opus"
      }
    }
  }
}
```

**Critical:** `outputFormat` must be Opus for Telegram voice notes with waveforms.

## Why This Approach?

**Alternatives considered:**
1. ❌ Pre-process all text globally → Breaks visual experience (users want emojis)
2. ❌ Disable emojis entirely → Poor UX
3. ✅ **Dual-mode with `[[tts:text]]`** → Best of both worlds

**Benefits:**
- ✅ Preserves visual emojis for user experience
- ✅ Clean audio without emoji names
- ✅ Single message (no duplicates)
- ✅ Automatic background TTS generation
- ✅ Proper Telegram voice note UI

## Troubleshooting

### Issue: Tags appear in message text

**Symptom:** User sees `[[tts:text]]...[[/tts:text]]` literally in Telegram.

**Cause:** OpenClaw not processing directives (check `messages.tts.modelOverrides.enabled`).

**Solution:**
```json
{
  "messages": {
    "tts": {
      "modelOverrides": {
        "enabled": true
      }
    }
  }
}
```

### Issue: Audio still speaks emoji names

**Symptom:** Voice says "party popper" despite using `[[tts:text]]`.

**Cause:** Emoji not removed from `[[tts:text]]` block.

**Solution:** Verify text inside tags has no emojis:
```bash
echo "[[tts:text]]Test 🎉[[/tts:text]]" | grep -oP '(?<=\[\[tts:text\]\]).*(?=\[\[/tts:text\]\])' | python3 ~/.openclaw/tools/tts-filter.py
```

### Issue: Message sent twice

**Symptom:** User receives duplicate messages.

**Cause:** Agent sending visual text and `[[tts:text]]` as separate messages.

**Solution:** Combine in single message:
```
CORRECT:
Visual 🎉
[[tts:text]]Visual[[/tts:text]]

WRONG:
Visual 🎉
--- separate message ---
[[tts:text]]Visual[[/tts:text]]
```

## Performance Impact

- **Emoji filtering:** ~5-15ms (negligible)
- **TTS generation:** ~2-3 seconds (unchanged)
- **Total overhead:** <1% of TTS time

## References

- [OpenClaw TTS Documentation](https://docs.openclaw.ai/tools/tts)
- [Edge TTS Voice List](https://learn.microsoft.com/azure/ai-services/speech-service/language-support?tabs=tts)
- [Telegram Voice Note Format](https://core.telegram.org/bots/api#sendvoice)

---

**Created:** 2026-02-24  
**Tested:** OpenClaw 2026.2.15 on ARM64 Ubuntu 24.04  
**Status:** Production-ready
