//
//  ToolbarView.swift
//  Scripter
//

import Adwaita
import Libadwaita

struct ToolbarView: View {

    var app: GTUIApp
    var window: GTUIApplicationWindow
    var run: () -> Void
    var export: () -> Void

    var view: Body {
        HeaderBar {
            Button("Run", icon: .default(icon: .mediaPlaybackStart)) {
                run()
            }
            .style("suggested-action")
        } end: {
            Menu(icon: .default(icon: .openMenu), app: app, window: window) {
                MenuButton("Run") {
                    run()
                }
                .keyboardShortcut("Return".ctrl())
                windowSection
                MenuSection {
                    MenuButton("About") {
                        app.addWindow("about", parent: window)
                    }
                }
            }
        }
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
