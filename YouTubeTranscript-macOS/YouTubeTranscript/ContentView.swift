import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = TranscriptViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("YouTube Transcript")
                .font(.largeTitle)
                .padding(.top)
            
            TextField("Enter YouTube URL", text: $viewModel.youtubeURL)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Get Transcript") {
                Task {
                    await viewModel.fetchTranscript()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !viewModel.transcript.isEmpty {
                ScrollView {
                    Text(viewModel.transcript)
                        .textSelection(.enabled)
                        .padding()
                }
                .frame(maxHeight: 300)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.saveTranscript()
                    }) {
                        Label("Save File", systemImage: "arrow.down.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        viewModel.shareTranscript()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.savedFileURL {
                ShareSheet(items: [url])
            }
        }
        .fileExporter(
            isPresented: $viewModel.showFileSaver,
            document: TextDocument(text: viewModel.transcript),
            contentType: .plainText,
            defaultFilename: "transcript_\(Date().timeIntervalSince1970).txt"
        ) { result in
            switch result {
            case .success(let url):
                print("✅ File saved to: \(url)")
            case .failure(let error):
                viewModel.errorMessage = "Failed to save: \(error.localizedDescription)"
            }
        }
    }
}

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
