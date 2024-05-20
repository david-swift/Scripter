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
        }
    }

}
