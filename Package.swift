// swift-tools-version: 5.8
//
//  Package.swift
//  Scripter
//

import PackageDescription

let package = Package(
    name: "Scripter",
    dependencies: [
        .package(url: "https://github.com/AparokshaUI/Adwaita", from: "0.1.9"),
        .package(url: "https://github.com/AparokshaUI/CodeEditor", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Scripter",
            dependencies: [
                .product(name: "Adwaita", package: "Adwaita"),
                .product(name: "CodeEditor", package: "CodeEditor")
            ],
            path: "Sources"
        )
    ]
)
