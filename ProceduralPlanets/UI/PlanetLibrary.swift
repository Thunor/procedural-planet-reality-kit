//
//  PlanetLibrary.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 8/16/24.
//

import Foundation
import SwiftUI
import SwiftData

struct PlanetLibrary: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(AppState.self) private var appState
    
    @Query(sort: \PlanetModel.name) private var planetModels: [PlanetModel]
    @State var selectedPlanet: PlanetModel?
    
    var body: some View {
        NavigationSplitView {
            VStack {
                if planetModels.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "globe")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Planets Yet")
                            .font(.title2)
                        Text("Create your first procedural planet to get started")
                            .foregroundStyle(.secondary)
                        Button("Add Planet") {
                            addPlanet()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedPlanet) {
                        ForEach(planetModels) { planet in
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(planet.name)
                                        .font(.headline)
                                    Text("Procedural Planet")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Edit") {
                                    let uuid = UUID()
                                    appState.planetModelMap[uuid] = planet
                                    openWindow(value: uuid)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete(perform: deletePlanets)
                    }
                }
            }
            .navigationTitle("Planet Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        addPlanet()
                    }) {
                        Label("Add Planet", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selectedPlanet {
                VStack(spacing: 20) {
                    Image(systemName: "globe")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    Text(selectedPlanet.name)
                        .font(.largeTitle)
                    Text("Procedural Planet")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Button("Open in Editor") {
                        let uuid = UUID()
                        appState.planetModelMap[uuid] = selectedPlanet
                        openWindow(value: uuid)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "sidebar.left")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("Select a Planet")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Choose a planet from the library to see details")
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func addPlanet() {
        let newPlanet = PlanetModel.samplePlanet()
        newPlanet.name = "Planet \(planetModels.count + 1)"
        modelContext.insert(newPlanet)
    }
    
    private func deletePlanets(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(planetModels[index])
        }
    }
    
}

#Preview {
    PlanetLibrary()
        .frame(width: 800, height: 600)
        .modelContainer(try! ModelContainer.sample())
}

extension ModelContainer {
    static var sample: () throws -> ModelContainer = {
        let schema = Schema([PlanetModel.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        Task { @MainActor in
            PlanetModel.insertSampleData(modelContext: container.mainContext)
        }
        return container
    }
}

extension PlanetModel {
    
    static func insertSampleData(modelContext: ModelContext) {
        let planetOne = PlanetModel.samplePlanet()
        planetOne.name = "Earth"
        
        let planetTwo = PlanetModel.samplePlanet()
        planetOne.name = "Mars"
        
        modelContext.insert(planetOne)
        modelContext.insert(planetTwo)
    }
    
}
