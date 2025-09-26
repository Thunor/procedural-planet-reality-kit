//
//  ProceduralPlanetsApp.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 7/15/24.
//

import SwiftUI
import SwiftData

@main
struct ProceduralPlanetsApp: App {
    
    @State var appState = AppState()
    
    var body: some Scene {
        
        WindowGroup {
            PlanetLibrary()
                .modelContainer(for: [
                    PlanetModel.self
                ])
                .environment(appState)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Planet") {
                    // This will be handled by the library view
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        WindowGroup("Planet Editor", for: UUID.self) { id in
            if let value = id.wrappedValue,
                let planetModel = appState.planetModelMap[value] {
                PlanetEditorView(planetModel: planetModel)
                    .environment(appState)
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .defaultSize(width: 1000, height: 700)
    }
    
}
