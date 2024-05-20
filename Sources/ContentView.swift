//
//  ContentView.swift
//  Scripter
//

import Adwaita
import CAdw
import CodeEditor
import Foundation

struct ContentView: WindowView {

    @State("text")
    private var text = ""
    @State("width")
    private var width = 400
    @State("height")
    private var height = 300
    @State private var output: [String] = []
    @State private var outputSignal: Signal = .init()
    @State("sidebar")
    private var sidebarVisible = false
    @State private var selectedText = ""
    @State private var copySignal: Signal = .init()
    @State private var alertDialog = false
    @State private var errorOutput = ""
    @Binding var exportContent: String
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var importContent: String

    var view: Body {
        OverlaySplitView(visible: $sidebarVisible) {
            ScrollView {
                List(output, selection: $selectedText) { output in
                    Text(output)
                        .halign(.start)
                        .padding()
                }
                .sidebarStyle()
            }
            .topToolbar {
                HeaderBar.start {
                    Button(icon: .default(icon: .editCopy)) {
                        copyOutput()
                    }
                }
                .headerBarTitle {
                    Text("History")
                        .heading()
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
            .inspectOnAppear { adw_toolbar_view_set_top_bar_style($0.pointer, ADW_TOOLBAR_RAISED) }
            .toast(output.first ?? "Error", signal: outputSignal)
        }
        .trailingSidebar()
        .alertDialog(visible: $alertDialog, heading: "An Error Occured", body: errorOutput)
        .response("Close") { }
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
            self.errorOutput = errorOutput
            alertDialog = true
        }
    }

    func export() {
        exportContent = text
    }

    func copyOutput() {
        State<Any>.copy(selectedText)
        copySignal.signal()
    }

    func window(_ window: Window) -> Window {
        window
            .size(width: $width, height: $height)
    }

}
