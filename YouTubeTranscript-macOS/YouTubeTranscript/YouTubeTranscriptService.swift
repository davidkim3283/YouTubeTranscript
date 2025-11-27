import Foundation

#if os(macOS)
import AppKit
#endif

struct VideoMetadata {
    let title: String
    let author: String
    let publishDate: String
    let videoID: String
}

class YouTubeTranscriptService {
    func fetchTranscript(videoID: String) async throws -> String {
        print("🔍 Fetching transcript for video ID: \(videoID)")
        
        // Fetch metadata and transcript
        let metadata = try await fetchMetadata(videoID: videoID)
        let transcript = try await fetchTranscriptViaPython(videoID: videoID)
        
        // Format with metadata header and smart paragraphs
        return formatTranscript(transcript: transcript, metadata: metadata)
    }
    
    private func fetchMetadata(videoID: String) async throws -> VideoMetadata {
        let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            throw TranscriptError.networkError("Failed to decode page")
        }
        
        // Extract metadata from HTML
        let title = extractMetadata(from: html, pattern: "<meta property=\"og:title\" content=\"([^\"]+)\"") ?? "Unknown Title"
        let author = extractMetadata(from: html, pattern: "\"author\":\"([^\"]+)\"") ?? "Unknown Author"
        let publishDate = extractMetadata(from: html, pattern: "\"publishDate\":\"([^\"]+)\"") ?? "Unknown Date"
        
        return VideoMetadata(title: title, author: author, publishDate: publishDate, videoID: videoID)
    }
    
    private func extractMetadata(from html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[range])
            .replacingOccurrences(of: "\\u0026", with: "&")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
    
    private func formatTranscript(transcript: String, metadata: VideoMetadata) -> String {
        var output = ""
        
        // Header
        output += "=" + String(repeating: "=", count: 60) + "\n"
        output += "YOUTUBE VIDEO TRANSCRIPT\n"
        output += "=" + String(repeating: "=", count: 60) + "\n\n"
        
        // Metadata
        output += "Title: \(metadata.title)\n"
        output += "Author: \(metadata.author)\n"
        output += "Published: \(metadata.publishDate)\n"
        output += "Video ID: \(metadata.videoID)\n"
        output += "URL: https://www.youtube.com/watch?v=\(metadata.videoID)\n"
        output += "Downloaded: \(Date().formatted(date: .abbreviated, time: .shortened))\n\n"
        
        output += "=" + String(repeating: "=", count: 60) + "\n"
        output += "TRANSCRIPT\n"
        output += "=" + String(repeating: "=", count: 60) + "\n\n"
        
        // Smart paragraph formatting with natural breaks
        let sentences = splitIntoSentences(transcript)
        var currentParagraph: [String] = []
        var wordCount = 0
        
        for sentence in sentences {
            let sentenceWords = sentence.split(separator: " ").count
            currentParagraph.append(sentence)
            wordCount += sentenceWords
            
            // Look for natural break points after reaching minimum word count
            if wordCount >= 100 {
                // Check if we should break here or wait for a better spot
                let shouldBreak = wordCount >= 150 || isNaturalBreakPoint(sentence)
                
                if shouldBreak {
                    output += currentParagraph.joined(separator: " ") + "\n\n"
                    currentParagraph = []
                    wordCount = 0
                }
            }
        }
        
        // Add remaining sentences
        if !currentParagraph.isEmpty {
            output += currentParagraph.joined(separator: " ") + "\n\n"
        }
        
        output += "=" + String(repeating: "=", count: 60) + "\n"
        output += "END OF TRANSCRIPT\n"
        output += "=" + String(repeating: "=", count: 60) + "\n"
        
        return output
    }
    
    private func splitIntoSentences(_ text: String) -> [String] {
        // Split on sentence-ending punctuation followed by space
        let pattern = "(?<=[.!?])\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [text]
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        var sentences: [String] = []
        var lastIndex = text.startIndex
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                let sentence = String(text[lastIndex..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                if !sentence.isEmpty {
                    sentences.append(sentence)
                }
                lastIndex = range.upperBound
            }
        }
        
        // Add the last sentence
        let lastSentence = String(text[lastIndex...]).trimmingCharacters(in: .whitespaces)
        if !lastSentence.isEmpty {
            sentences.append(lastSentence)
        }
        
        return sentences
    }
    
    private func isNaturalBreakPoint(_ sentence: String) -> Bool {
        let trimmed = sentence.trimmingCharacters(in: .whitespaces)
        
        // Natural break indicators
        let breakPhrases = [
            "however", "therefore", "meanwhile", "furthermore", "moreover",
            "in addition", "on the other hand", "in conclusion", "finally",
            "first", "second", "third", "next", "then", "now", "so"
        ]
        
        let lowerSentence = trimmed.lowercased()
        
        // Check if sentence starts with a transition word/phrase
        for phrase in breakPhrases {
            if lowerSentence.hasPrefix(phrase + " ") || lowerSentence.hasPrefix(phrase + ",") {
                return true
            }
        }
        
        // Prefer breaks after questions or exclamations
        if trimmed.hasSuffix("?") || trimmed.hasSuffix("!") {
            return true
        }
        
        return false
    }
    
    private func fetchTranscriptViaPython(videoID: String) async throws -> String {
        #if os(macOS)
        let pythonScript = """
        import sys
        try:
            from youtube_transcript_api import YouTubeTranscriptApi
            
            api = YouTubeTranscriptApi()
            transcript_list = api.list('\(videoID)')
            
            # Try to find English transcript first
            try:
                transcript = transcript_list.find_transcript(['en', 'en-US', 'en-GB'])
            except:
                # Get first available transcript
                transcript = next(iter(transcript_list))
            
            fetched = transcript.fetch()
            result = []
            for entry in fetched.snippets:
                result.append(entry.text)
            
            print(' '.join(result))
        except Exception as e:
            print(f"ERROR: {e}", file=sys.stderr)
            sys.exit(1)
        """
        
        // Get the path to the venv Python
        let venvPython = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Kiro/YouTubeTranscript/.venv/bin/python3")
        
        let process = Process()
        if FileManager.default.fileExists(atPath: venvPython.path) {
            process.executableURL = venvPython
            process.arguments = ["-c", pythonScript]
        } else {
            // Fallback to system python3
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["python3", "-c", pythonScript]
        }
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try process.run()
                
                process.terminationHandler = { _ in
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
                        print("❌ Python error: \(error)")
                        
                        if error.contains("No module named") {
                            continuation.resume(throwing: TranscriptError.networkError("Python library not installed. Run: pip3 install youtube-transcript-api"))
                        } else {
                            continuation.resume(throwing: TranscriptError.noTranscriptAvailable)
                        }
                        return
                    }
                    
                    if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
                        let transcript = output.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("✅ Successfully fetched transcript, length: \(transcript.count)")
                        continuation.resume(returning: transcript)
                    } else {
                        continuation.resume(throwing: TranscriptError.noTranscriptAvailable)
                    }
                }
            } catch {
                continuation.resume(throwing: TranscriptError.networkError("Failed to run Python: \(error.localizedDescription)"))
            }
        }
        #else
        // iOS doesn't support Process, so we need a different approach
        throw TranscriptError.networkError("This feature is only available on macOS")
        #endif
    }
}
