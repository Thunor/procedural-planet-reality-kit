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
    
    var sharedModelContainer: ModelContainer = {
        do {
            // Try the simplest possible configuration first
            return try ModelContainer(for: PlanetModel.self)
        } catch {
            print("Failed to create ModelContainer with PlanetModel: \(error)")
            
            // Fallback to in-memory container for debugging
            do {
                let schema = Schema([PlanetModel.self])
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            PlanetLibrary()
                .modelContainer(sharedModelContainer)
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
                    .modelContainer(sharedModelContainer)
                    .environment(appState)
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .defaultSize(width: 1000, height: 700)
    }
    
}
