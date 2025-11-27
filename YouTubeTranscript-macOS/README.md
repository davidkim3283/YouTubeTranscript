# YouTube Transcript Extractor (macOS)

Extract YouTube video transcripts with metadata and smart formatting.

## Features

- ✅ Extract transcripts from any YouTube video with captions
- ✅ Includes video metadata (title, author, publish date)
- ✅ Smart paragraph formatting with natural breaks
- ✅ Save transcripts as formatted text files
- ✅ Share via macOS share sheet
- ✅ No API keys or authentication required
- ✅ Works reliably with Python backend

## For Users

### Download & Run

1. **Download** the latest release from GitHub
2. **Open** YouTubeTranscript.app
3. **Paste** a YouTube URL
4. **Click** "Get Transcript"
5. **Save** or share your transcript!

### First Time Setup

If you see a security warning:
1. Right-click the app → Open
2. Click "Open" in the dialog
3. macOS will remember your choice

## For Developers

### Requirements

- macOS 13.0+
- Xcode 15.0+
- Python 3.9+

### Setup

```bash
# Clone the repository
git clone https://github.com/davidkim3283/YouTubeTranscript.git
cd YouTubeTranscript/YouTubeTranscript

# Setup Python environment
chmod +x setup_bundle.sh
./setup_bundle.sh

# Open in Xcode
open YouTubeTranscript.xcodeproj
```

### Building for Distribution

1. **Run setup script:**
   ```bash
   ./setup_bundle.sh
   ```

2. **In Xcode:**
   - Product → Archive
   - Distribute App → Copy App
   - Choose destination

3. **The app bundle includes:**
   - Swift app binary
   - Python virtual environment (.venv)
   - All dependencies (youtube-transcript-api)

### How It Works

The app uses a hybrid approach:
- **Swift UI** for the native macOS interface
- **Python** for reliable YouTube transcript extraction
- **Virtual environment** bundled with the app for portability

The Python script runs in a subprocess and communicates via stdout/stderr.

## Architecture

```
YouTubeTranscript.app/
├── Contents/
│   ├── MacOS/
│   │   └── YouTubeTranscript (Swift binary)
│   └── Resources/
│       └── .venv/ (Python environment)
│           ├── bin/python3
│           └── lib/python3.x/site-packages/
│               └── youtube_transcript_api/
```

## Troubleshooting

### "App is damaged" error
```bash
xattr -cr YouTubeTranscript.app
```

### Python not found
The app looks for Python at:
1. `~/Kiro/YouTubeTranscript/.venv/bin/python3`
2. System `python3`

Run `./setup_bundle.sh` to create the virtual environment.

### No transcript available
- Check if the video has captions enabled
- Try a different video
- Some videos may have captions disabled by the creator

## License

MIT License - feel free to use and modify!

## Credits

Uses [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) for transcript extraction.
