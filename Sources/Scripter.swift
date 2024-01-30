//
//  Scripter.swift
//  Scripter
//

import Adwaita

@main
struct Scripter: App {

    @State private var importContent = ""
    @State private var exportContent = ""
    let id = "io.github.david_swift.Scripter"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(exportContent: $exportContent, app: app, window: window, importContent: importContent)
        }
        .defaultSize(width: 400, height: 300)
        .quitShortcut()
        .overlay {
            FileDialog(importer: "importer", extensions: ["py"]) { url in
                if let content = try? String(contentsOf: url) {
                    importContent = content
                    app.addWindow("main")
                    importContent = ""
                }
            } onClose: {
                importContent = ""
            }
            FileDialog(exporter: "exporter", initialName: "Script.py") { url in
                try? exportContent.write(toFile: url.path, atomically: false, encoding: .utf8)
            } onClose: {
                exportContent = ""
            }
            AboutWindow(id: "about", appName: "Scripter", developer: "david-swift", version: "0.1.1")
                .icon(.custom(name: "io.github.david_swift.Scripter"))
                .website(.init(string: "https://github.com/david-swift/Scripter"))
                .issues(.init(string: "https://github.com/david-swift/Scripter/issues"))
        }
    }

}
