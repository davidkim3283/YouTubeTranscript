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
        
        # Get metadata (basic info)
        metadata = {
            'video_id': video_id,
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
