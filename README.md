# YouTube Transcript API Backend

Simple Flask API for fetching YouTube transcripts. Designed to work with the iOS YouTube Transcript app.

## Endpoints

- `GET /` - API info
- `GET /health` - Health check
- `GET /transcript/<video_id>` - Get transcript for a video

## Example Response

```json
{
  "success": true,
  "transcript": "Full transcript text here...",
  "metadata": {
    "video_id": "dQw4w9WgXcQ",
    "language": "English",
    "language_code": "en",
    "is_generated": true,
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "fetched_at": "2024-11-26T19:00:00"
  }
}
```

## Deploy to Render

1. Push this code to a GitHub repository
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Click "New +" → "Web Service"
4. Connect your GitHub repository
5. Render will auto-detect the `render.yaml` configuration
6. Click "Create Web Service"
7. Wait for deployment (2-3 minutes)
8. Copy your service URL (e.g., `https://your-app.onrender.com`)

## Local Development

```bash
pip install -r requirements.txt
python app.py
```

Visit `http://localhost:10000`

## Usage

```bash
# Test the API
curl https://your-app.onrender.com/transcript/dQw4w9WgXcQ
```

## Notes

- Free tier on Render spins down after 15 minutes of inactivity
- First request after spin-down may take 30-60 seconds
- Upgrade to paid tier ($7/month) for always-on service
