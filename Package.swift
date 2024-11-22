// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "WebDriverAgent",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "WebDriverAgent",
            targets: ["WebDriverAgent"]),
    ],
    targets: [
        .target(
            name: "WebDriverAgent",
            path: ".",
            exclude: [
                "README.md",
                "LICENSE",
                "WebDriverAgent.xcodeproj",
                "WebDriverAgentRunner",
                "WebDriverAgentTests",
            ],
            sources: [
                "WebDriverAgentLib"
            ],
            publicHeadersPath: "WebDriverAgentLib",
            cSettings: [
                .headerSearchPath("PrivateHeaders"),
                .headerSearchPath("WebDriverAgentLib")
            ]
        )
    ]
)
