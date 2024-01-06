//
//  ContentView.swift
//  Scripter
//

import Adwaita
import CodeEditor
import Foundation
import Libadwaita

struct ContentView: View {

    @State("text")
    private var text = ""
    @State private var output: [String] = []
    @State private var outputSignal: Signal = .init()
    @State("sidebar")
    private var sidebarVisible = false
    @State private var selectedText = ""
    @State private var copySignal: Signal = .init()
    @Binding var exportContent: String
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var importContent: String

    var view: Body {
        OverlaySplitView(visible: sidebarVisible) {
            ScrollView {
                List(output, selection: $selectedText) { output in
                    Text(output)
                        .halign(.start)
                        .padding()
                }
                .style("navigation-sidebar")
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
        let process = Process()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/python3")
        process.arguments = ["-c", text]

        let pipe = Pipe()
        process.standardOutput = pipe

        let errors = Pipe()
        process.standardError = errors

        try? process.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let output = output.components(separatedBy: "\n").filter { !$0.isEmpty }
            for element in output {
                self.output.insert(element, at: 0)
                selectedText = element
                if !sidebarVisible {
                    outputSignal.signal()
                }
            }
        }

        let errorData = errors.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            let dialog = MessageDialog(parent: window, heading: "An Error Occured", body: errorOutput)
                .response(
                    id: "close",
                    label: "Close",
                    type: .closeResponse
                ) { }
            dialog.show()
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
