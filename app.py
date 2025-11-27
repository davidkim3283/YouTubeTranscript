from flask import Flask, jsonify, request
from flask_cors import CORS
from youtube_transcript_api import YouTubeTranscriptApi
from datetime import datetime
import re

app = Flask(__name__)
CORS(app)  # Allow requests from iOS app

@app.route('/')
def home():
    return jsonify({
        'status': 'ok',
        'message': 'YouTube Transcript API',
        'endpoints': {
            '/transcript/<video_id>': 'GET - Fetch transcript for a video',
            '/health': 'GET - Health check'
        }
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/transcript/<video_id>')
def get_transcript(video_id):
    try:
        import requests
        
        # Fetch transcript using youtube-transcript-api
        api = YouTubeTranscriptApi()
        transcript_list = api.list(video_id)
        
        # Try to find English transcript first
        try:
            transcript = transcript_list.find_transcript(['en', 'en-US', 'en-GB'])
        except:
            # Get first available transcript
            transcript = next(iter(transcript_list))
        
        fetched = transcript.fetch()
        
        # Extract text from snippets
        text_parts = []
        for entry in fetched.snippets:
            text_parts.append(entry.text)
        
        full_transcript = ' '.join(text_parts)
        
        # Fetch video metadata from YouTube page
        try:
            video_url = f'https://www.youtube.com/watch?v={video_id}'
            headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'}
            response = requests.get(video_url, headers=headers, timeout=10)
            html = response.text
            
            # Extract title
            title_match = re.search(r'<meta property="og:title" content="([^"]+)"', html)
            title = title_match.group(1) if title_match else "Unknown Title"
            
            # Extract author
            author_match = re.search(r'"author":"([^"]+)"', html)
            author = author_match.group(1) if author_match else "Unknown Author"
            
            # Extract publish date
            date_match = re.search(r'"publishDate":"([^"]+)"', html)
            publish_date = date_match.group(1) if date_match else "Unknown Date"
        except:
            title = "Unknown Title"
            author = "Unknown Author"
            publish_date = "Unknown Date"
        
        # Get metadata
        metadata = {
            'video_id': video_id,
            'title': title,
            'author': author,
            'publish_date': publish_date,
            'language': fetched.language,
            'language_code': fetched.language_code,
            'is_generated': fetched.is_generated,
            'url': f'https://www.youtube.com/watch?v={video_id}',
            'fetched_at': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'transcript': full_transcript,
            'metadata': metadata
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000)
