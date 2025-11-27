# Distribution Guide

How to package and distribute the YouTube Transcript app to other users.

## Quick Distribution (Easiest)

### Option 1: Direct App Bundle

1. **Build the app:**
   ```bash
   ./setup_bundle.sh
   ```

2. **In Xcode:**
   - Product → Build (Cmd+B)
   - Product → Show Build Folder in Finder
   - Navigate to: `Products/Debug/YouTubeTranscript.app`

3. **Zip the app:**
   ```bash
   cd ~/Library/Developer/Xcode/DerivedData/YouTubeTranscript-*/Build/Products/Debug
   zip -r YouTubeTranscript.zip YouTubeTranscript.app
   ```

4. **Share the zip file** - Users can unzip and run!

### Option 2: GitHub Release

1. **Create a release on GitHub**
2. **Upload the .zip file**
3. **Users download and run**

## Professional Distribution

### Code Signing (Recommended)

For wider distribution without security warnings:

1. **Get an Apple Developer account** ($99/year)

2. **Sign the app:**
   - In Xcode → Target → Signing & Capabilities
   - Select your Team
   - Enable "Hardened Runtime"

3. **Notarize the app:**
   ```bash
   # Archive
   xcodebuild -project YouTubeTranscript.xcodeproj \
              -scheme YouTubeTranscript \
              -configuration Release \
              archive -archivePath YouTubeTranscript.xcarchive
   
   # Export
   xcodebuild -exportArchive \
              -archivePath YouTubeTranscript.xcarchive \
              -exportPath . \
              -exportOptionsPlist ExportOptions.plist
   
   # Notarize
   xcrun notarytool submit YouTubeTranscript.zip \
                          --apple-id your@email.com \
                          --team-id TEAMID \
                          --password app-specific-password
   ```

### DMG Installer (Professional)

Create a nice drag-and-drop installer:

```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "YouTube Transcript" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "YouTubeTranscript.app" 200 190 \
  --hide-extension "YouTubeTranscript.app" \
  --app-drop-link 600 185 \
  "YouTubeTranscript.dmg" \
  "YouTubeTranscript.app"
```

## What Gets Bundled

The app bundle includes:
- ✅ Swift binary
- ✅ Python virtual environment (.venv)
- ✅ youtube-transcript-api library
- ✅ All Python dependencies

Users don't need to install anything!

## User Instructions

Include these instructions with your distribution:

### For First-Time Users

1. **Download** YouTubeTranscript.zip
2. **Unzip** the file
3. **Drag** YouTubeTranscript.app to Applications folder
4. **Right-click** the app → Open (first time only)
5. **Click** "Open" in the security dialog

### If Security Warning Appears

```bash
xattr -cr /Applications/YouTubeTranscript.app
```

Then try opening again.

## Testing Before Distribution

Test on a clean Mac (or VM) to ensure:
- [ ] App opens without errors
- [ ] Python environment is found
- [ ] Transcripts download successfully
- [ ] Save/Share functions work
- [ ] No external dependencies needed

## File Size

Expected app bundle size:
- App binary: ~5 MB
- Python + dependencies: ~15 MB
- **Total: ~20 MB**

## Distribution Checklist

- [ ] Run `./setup_bundle.sh`
- [ ] Build in Release mode
- [ ] Test on clean system
- [ ] Create zip file
- [ ] Write release notes
- [ ] Upload to GitHub Releases
- [ ] Update README with download link

## Support

For issues, direct users to:
- GitHub Issues
- README troubleshooting section
- Your contact info
