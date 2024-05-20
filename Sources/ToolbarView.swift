//
//  ToolbarView.swift
//  Scripter
//

import Adwaita

struct ToolbarView: View {

    @Binding var sidebarVisible: Bool
    @State private var aboutDialog = false
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var run: () -> Void
    var export: () -> Void
    var copyOutput: () -> Void

    var view: Body {
        HeaderBar {
            Button("Run", icon: .default(icon: .mediaPlaybackStart)) {
                run()
            }
            .style("suggested-action")
        } end: {
            menu
            Toggle(icon: .default(icon: .sidebarShowRight), isOn: $sidebarVisible)
        }
    }

    @ViewBuilder var menu: Body {
        Menu(icon: .default(icon: .openMenu), app: app, window: window) {
            MenuButton("Run") {
                run()
            }
            .keyboardShortcut("Return".ctrl())
            windowSection
            MenuSection {
                MenuButton("Copy Output") {
                    copyOutput()
                }
                .keyboardShortcut("c".shift().ctrl())
            }
            MenuSection {
                MenuButton("About") {
                    aboutDialog = true
                }
            }
        }
        .aboutDialog(
            visible: $aboutDialog,
            app: "Scripter",
            developer: "david-swift",
            version: "0.1.2",
            icon: .custom(name: "io.github.david_swift.Scripter"),
            website: .init(string: "https://github.com/david-swift/Scripter"),
            issues: .init(string: "https://github.com/david-swift/Scripter/issues")
        )
    }

    @MenuBuilder var windowSection: MenuContent {
        MenuSection {
            Submenu("Window") {
                MenuButton("New Window", window: false) {
                    app.addWindow("main")
                }
                .keyboardShortcut("n".ctrl())
                MenuButton("Close Window") {
                    window.close()
                }
                .keyboardShortcut("w".ctrl())
            }
            MenuButton("Import File...") {
                app.addWindow("importer", parent: window)
            }
            .keyboardShortcut("i".ctrl())
            MenuButton("Export File...") {
                export()
                app.addWindow("exporter", parent: window)
            }
            .keyboardShortcut("e".ctrl())
        }
    }

}
