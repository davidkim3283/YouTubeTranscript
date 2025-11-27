import Foundation

class PythonBridge {
    static func ensurePythonSetup() async throws {
        // Check if youtube-transcript-api is installed
        let checkProcess = Process()
        checkProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        checkProcess.arguments = ["python3", "-c", "import youtube_transcript_api"]
        
        let pipe = Pipe()
        checkProcess.standardError = pipe
        
        try checkProcess.run()
        checkProcess.waitUntilExit()
        
        if checkProcess.terminationStatus != 0 {
            // Library not installed, show instructions
            throw PythonSetupError.libraryNotInstalled
        }
    }
    
    static func getSetupInstructions() -> String {
        """
        YouTube Transcript API Setup Required
        
        This app requires the youtube-transcript-api Python library.
        
        To install it, open Terminal and run:
        
        python3 -m pip install --user youtube-transcript-api
        
        Or if you have Homebrew:
        
        brew install python
        python3 -m pip install --user youtube-transcript-api
        
        Then restart this app.
        """
    }
}

enum PythonSetupError: LocalizedError {
    case libraryNotInstalled
    
    var errorDescription: String? {
        PythonBridge.getSetupInstructions()
    }
}
