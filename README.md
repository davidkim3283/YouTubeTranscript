# YouTube Transcript Tools

Extract YouTube video transcripts with ease!

## 📦 What's Included

### 1. **macOS App** (Recommended) ⭐
Native macOS application with Python backend.

**Location:** `YouTubeTranscript-macOS/`

**Features:**
- ✅ Native macOS interface
- ✅ Reliable Python-based extraction
- ✅ Smart paragraph formatting
- ✅ Video metadata (title, author, date)
- ✅ Save & share transcripts
- ✅ No API keys needed

**[Download Latest Release →](https://github.com/davidkim3283/YouTubeTranscript/releases)**

### 2. **Backend API** (Optional)
Flask API for programmatic access.

**Location:** Root directory

**Use if you need:**
- Web service integration
- Multiple client support
- Remote transcript extraction

**Deployed at:** https://youtubetranscript-fixb.onrender.com

---

## 🚀 Quick Start

### For Users (macOS App)

1. **Download** the latest release
2. **Unzip** and drag to Applications
3. **Open** the app (right-click → Open first time)
4. **Paste** a YouTube URL
5. **Get your transcript!**

### For Developers (macOS App)

```bash
# Clone the repo
git clone https://github.com/davidkim3283/YouTubeTranscript.git
cd YouTubeTranscript/YouTubeTranscript-macOS

# Setup Python environment
./setup_bundle.sh

# Open in Xcode
open YouTubeTranscript.xcodeproj
```

### For Developers (Backend API)

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python app.py

# Or deploy to Render/Railway/etc
```

---

## 📖 Documentation

- **macOS App:** See `YouTubeTranscript-macOS/README.md`
- **Distribution:** See `YouTubeTranscript-macOS/DISTRIBUTION.md`
- **Backend API:** See API endpoints below

---

## 🔌 API Endpoints

### `GET /`
API information and available endpoints

### `GET /health`
Health check

### `GET /transcript/<video_id>`
Get transcript for a YouTube video

**Example:**
```bash
curl https://youtubetranscript-fixb.onrender.com/transcript/dQw4w9WgXcQ
```

**Response:**
```json
{
  "success": true,
  "transcript": "Full transcript text...",
  "metadata": {
    "video_id": "dQw4w9WgXcQ",
    "title": "Video Title",
    "author": "Channel Name",
    "publish_date": "2009-10-25",
    "language": "English",
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }
}
```

---

## 🛠️ Tech Stack

- **macOS App:** Swift, SwiftUI, Python
- **Backend:** Flask, youtube-transcript-api
- **Deployment:** Render (free tier)

---

## ⚠️ Limitations

- Only works with videos that have captions enabled
- Some videos may have captions disabled by creators
- Backend API may be rate-limited by YouTube

---

## 📝 License

MIT License - feel free to use and modify!

---

## 🙏 Credits

Uses [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) for reliable transcript extraction.

---

## 🐛 Issues & Support

Found a bug? Have a feature request?

**[Open an Issue →](https://github.com/davidkim3283/YouTubeTranscript/issues)**
