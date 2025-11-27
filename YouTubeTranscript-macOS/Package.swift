// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YouTubeTranscript",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "YouTubeTranscript",
            targets: ["YouTubeTranscript"]),
    ],
    targets: [
        .target(
            name: "YouTubeTranscript"),
        .testTarget(
            name: "YouTubeTranscriptTests",
            dependencies: ["YouTubeTranscript"]),
    ]
)
