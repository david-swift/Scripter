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
    @State private var output: [String] = []
    @State private var outputSignal: Signal = .init()
    @State private var sidebarVisible = false
    @State private var selectedText = ""
    @State private var copySignal: Signal = .init()
    @Binding var exportContent: String
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var importContent: String
    let box = Libadwaita.ListBox()

    var view: Body {
        OverlaySplitView(visible: sidebarVisible) {
            ScrollView {
                box
                    .style("navigation-sidebar")
                    .onAppear {
                        _ = box.handler {
                            if let text = output[safe: box.getSelectedRow()] {
                                selectedText = text
                            }
                        }
                    }
            }
            .topToolbar {
                HeaderBar.start {
                    Button(icon: .default(icon: .editCopy)) {
                        copyOutput()
                    }
                }
                .headerBarTitle {
                    Text("History")
                        .style("heading")
                }
            }
            .toast("Copied \"\(selectedText)\"", signal: copySignal)
        } content: {
            ScrollView {
                CodeEditor(text: $text)
                    .innerPadding()
                    .lineNumbers()
                    .language(.python)
            }
            .vexpand()
            .topToolbar {
                ToolbarView(
                    sidebarVisible: $sidebarVisible,
                    app: app,
                    window: window,
                    run: run,
                    export: export,
                    copyOutput: copyOutput
                )
            }
            .inspect { _ = ($0 as? Libadwaita.ToolbarView)?.topBarStyle(.raised) }
            .toast(output.first ?? "Error", signal: outputSignal)
        }
        .trailingSidebar()
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
                    self.output.insert(element, at: 0)
                    _ = box.prepend(Label(element).halign(.start))
                    box.selectRow(at: 0)
                    if !sidebarVisible {
                        outputSignal.signal()
                    }
                }
            }
        }
    }

    func export() {
        exportContent = text
    }

    func copyOutput() {
        Clipboard.copy(selectedText)
        copySignal.signal()
    }

}
