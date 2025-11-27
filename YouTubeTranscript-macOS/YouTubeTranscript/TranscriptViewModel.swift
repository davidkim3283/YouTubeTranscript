import SwiftUI
import UniformTypeIdentifiers

@MainActor
class TranscriptViewModel: ObservableObject {
    @Published var youtubeURL: String = ""
    @Published var transcript: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showShareSheet: Bool = false
    @Published var showFileSaver: Bool = false
    @Published var savedFileURL: URL?
    
    private let transcriptService = YouTubeTranscriptService()
    
    func fetchTranscript() async {
        guard !youtubeURL.isEmpty else {
            errorMessage = "Please enter a YouTube URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        transcript = ""
        
        do {
            let videoID = try extractVideoID(from: youtubeURL)
            transcript = try await transcriptService.fetchTranscript(videoID: videoID)
            saveTranscriptLocally()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func extractVideoID(from url: String) throws -> String {
        // Handle various YouTube URL formats
        let patterns = [
            "(?:youtube\\.com/watch\\?v=|youtu\\.be/)([^&\\s]+)",
            "youtube\\.com/embed/([^&\\s]+)",
            "youtube\\.com/v/([^&\\s]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        
        throw TranscriptError.invalidURL
    }
    
    private func saveTranscriptLocally() {
        let fileName = "transcript_\(Date().timeIntervalSince1970).txt"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try transcript.write(to: fileURL, atomically: true, encoding: .utf8)
            savedFileURL = fileURL
        } catch {
            errorMessage = "Failed to save transcript: \(error.localizedDescription)"
        }
    }
    
    func saveTranscript() {
        showFileSaver = true
    }
    
    func shareTranscript() {
        showShareSheet = true
    }
}

enum TranscriptError: LocalizedError {
    case invalidURL
    case noTranscriptAvailable
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid YouTube URL"
        case .noTranscriptAvailable:
            return "No transcript available for this video"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
