//
//  ContentView.swift
//  Scripter
//

import Adwaita
import CodeEditor
import Foundation
import Libadwaita

struct ContentView: View {

    @State private var text = ""
    @State private var output = ""
    @State private var outputSignal: Signal = .init()
    @Binding var exportContent: String
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var importContent: String

    var view: Body {
        ScrollView {
            CodeEditor(text: $text)
                .innerPadding()
                .lineNumbers()
                .language(.python)
        }
        .vexpand()
        .topToolbar {
            ToolbarView(app: app, window: window, run: run, export: export)
        }
        .inspect { _ = ($0 as? Libadwaita.ToolbarView)?.topBarStyle(.raised) }
        .toast(output, signal: outputSignal)
        .onAppear {
            text = importContent
        }
    }

    func run() {
        Task {
            let process = Process()
            process.executableURL = .init(fileURLWithPath: "/usr/bin/python3")
            process.arguments = ["-c", text]

            let pipe = Pipe()
            process.standardOutput = pipe
            try process.run()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let output = output.components(separatedBy: "\n").filter { !$0.isEmpty }
                for element in output {
                    self.output = element
                    outputSignal.signal()
                }
            }
        }
    }

    func export() {
        exportContent = text
    }

}
