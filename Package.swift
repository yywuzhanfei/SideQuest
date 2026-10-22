// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SideQuest",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SideQuest", targets: ["SideQuest"])
    ],
    targets: [
        .executableTarget(
            name: "SideQuest"
        ),
        .testTarget(
            name: "SideQuestTests",
            dependencies: ["SideQuest"]
        )
    ]
)
