//
//  PlanetLibrary.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 8/16/24.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Compression

struct PlanetLibrary: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(AppState.self) private var appState
    
    @Query(sort: \PlanetModel.name) private var planetModels: [PlanetModel]
    @State var selectedPlanet: PlanetModel?
    @State private var editingPlanet: PlanetModel?
    @State private var editingName: String = ""
    @State private var showingExportDialog = false
    @State private var exportingPlanet: PlanetModel?
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(minWidth: 700, minHeight: 500)
        .fileExporter(
            isPresented: $showingExportDialog,
            document: exportingPlanet.map { KMZDocument(planet: $0) },
            contentType: .kmz,
            defaultFilename: exportingPlanet?.name ?? "Planet"
        ) { result in
            switch result {
            case .success(let url):
                print("KMZ file exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
            exportingPlanet = nil
            showingExportDialog = false
        }
    }
    
    @ViewBuilder
    private var sidebarContent: some View {
        VStack {
            if planetModels.isEmpty {
                emptyStateView
            } else {
                planetListView
            }
        }
        .navigationTitle("Planet Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addPlanet) {
                    Label("Add Planet", systemImage: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
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
    }
    
    @ViewBuilder
    private var planetListView: some View {
        List(selection: $selectedPlanet) {
            ForEach(planetModels) { planet in
                PlanetListRowView(
                    planet: planet,
                    editingPlanet: $editingPlanet,
                    editingName: $editingName,
                    selectedPlanet: $selectedPlanet,
                    exportingPlanet: $exportingPlanet,
                    showingExportDialog: $showingExportDialog,
                    onCommitNameEdit: { commitNameEdit(for: $0) },
                    onStartEditingName: { startEditingName(for: $0) },
                    onOpenWindow: { uuid in openWindow(value: uuid) },
                    appState: appState
                )
            }
            .onDelete(perform: deletePlanets)
        }
        .onTapGesture {
            // Cancel editing when tapping elsewhere
            if let editingPlanet = editingPlanet {
                commitNameEdit(for: editingPlanet)
            }
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        if let selectedPlanet {
            selectedPlanetView(selectedPlanet)
        } else {
            placeholderView
        }
    }
    
    @ViewBuilder
    private func selectedPlanetView(_ planet: PlanetModel) -> some View {
        ZStack {
            // 3D Planet view with mouse wheel zoom
            PlanetViewWithZoom(planet: planet)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            // Planet name and info header
            VStack(spacing: 8) {
                Text(planet.name)
                    .font(.largeTitle)
                    .padding(.top)
                Spacer()
            }
            .padding()
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder
    private var placeholderView: some View {
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
    
    private func startEditingName(for planet: PlanetModel) {
        editingPlanet = planet
        editingName = planet.name
    }
    
    private func commitNameEdit(for planet: PlanetModel) {
        planet.name = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        if planet.name.isEmpty {
            planet.name = "Unnamed Planet"
        }
        editingPlanet = nil
        editingName = ""
    }
}

// MARK: - Planet View with Mouse Wheel Zoom

struct PlanetViewWithZoom: NSViewRepresentable {
    let planet: PlanetModel
    
    func makeNSView(context: Context) -> ZoomCapableHostingView {
        let planetView = PlanetView(viewModel: PlanetEditorViewModel(planetModel: planet))
        let hostingView = ZoomCapableHostingView(rootView: planetView)
        return hostingView
    }
    
    func updateNSView(_ nsView: ZoomCapableHostingView, context: Context) {
        // Create a new PlanetView with the updated planet model
        let newPlanetView = PlanetView(viewModel: PlanetEditorViewModel(planetModel: planet))
        nsView.rootView = newPlanetView
    }
}

class ZoomCapableHostingView: NSHostingView<PlanetView> {
    private var currentZoom: CGFloat = 1.0
    
    override func scrollWheel(with event: NSEvent) {
        // Only handle zoom if we're scrolling vertically
        guard abs(event.scrollingDeltaY) > abs(event.scrollingDeltaX) else {
            super.scrollWheel(with: event)
            return
        }
        
        let zoomSensitivity: CGFloat = 0.02
        let zoomDelta = event.scrollingDeltaY * zoomSensitivity
        let newZoom = currentZoom + zoomDelta
        
        // Clamp zoom between 0.5x and 3.0x
        currentZoom = max(0.5, min(3.0, newZoom))
        
        // Apply zoom centered on the view
        let centerX = bounds.midX
        let centerY = bounds.midY
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: centerX, y: centerY)
        transform = transform.scaledBy(x: currentZoom, y: currentZoom)
        transform = transform.translatedBy(x: -centerX, y: -centerY)
        
        layer?.setAffineTransform(transform)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
}

// MARK: - Planet List Row View

struct PlanetListRowView: View {
    let planet: PlanetModel
    @Binding var editingPlanet: PlanetModel?
    @Binding var editingName: String
    @Binding var selectedPlanet: PlanetModel?
    @Binding var exportingPlanet: PlanetModel?
    @Binding var showingExportDialog: Bool
    let onCommitNameEdit: (PlanetModel) -> Void
    let onStartEditingName: (PlanetModel) -> Void
    let onOpenWindow: (UUID) -> Void
    let appState: AppState
    
    var body: some View {
        HStack {
            planetInfoSection
            Spacer(minLength: 6)
            actionButtonsSection
        }
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private var planetInfoSection: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                if editingPlanet == planet {
                    TextField("Planet name", text: $editingName)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            onCommitNameEdit(planet)
                        }
                        .onAppear {
                            editingName = planet.name
                        }
                } else {
                    Text(planet.name)
                        .font(.headline)
                        .onTapGesture(count: 2) {
                            onStartEditingName(planet)
                        }
                }
                Text("Procedural Planet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.background, lineWidth: 2.0)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if editingPlanet != planet {
                debugPrint("Selecting planet: \(planet.name)")
                selectedPlanet = planet
            }
        }
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        HStack(spacing: 4) {
//            Button("Export") {
//                print("Export button clicked for planet: \(planet.name)")
//                exportingPlanet = planet
//                showingExportDialog = true
//                print("showingExportDialog set to: \(showingExportDialog)")
//            }
//            .buttonStyle(.bordered)
//            .controlSize(.small)
            
            Button("Edit") {
                let uuid = UUID()
                appState.planetModelMap[uuid] = planet
                onOpenWindow(uuid)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
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
        planetTwo.name = "Mars"
        // Add craters to Mars
        let craterLayer = NoiseLayer(
            enabled: true,
            useFirstLayerAsMask: false,
            noiseSettings: NoiseSettings(
                numberOfLayers: 1,
                persistance: 0.5,
                baseRoughness: 1.0,
                strength: 0.3,
                roughness: 1.0,
                center: SIMD3<Float>(0, 0, 0),
                minValue: 0.0
            ),
            craterSettings: CraterSettings(
                craterCount: 75,
                minRadius: 0.01,
                maxRadius: 0.08,
                rimHeight: 0.4,
                rimWidth: 0.15,
                depth: 0.6,
                randomSeed: 54321,
                distribution: .uniform,
                fadeDistance: 0.9
            ),
            layerType: .craters
        )
        planetTwo.meshConfiguration.shapeSettings.noiseLayers.append(craterLayer)
        
        modelContext.insert(planetOne)
        modelContext.insert(planetTwo)
    }
    
}

// MARK: - KMZ Export Support

struct KMZDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.kmz] }
    
    let planet: PlanetModel
    
    init(planet: PlanetModel) {
        self.planet = planet
    }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.fileReadCorruptFile)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let kmlContent = generateKMLContent()
        let kmlData = kmlContent.data(using: .utf8)!
        
        // Create a simple ZIP archive with just the KML file
        let zipData = try createSimpleZip(filename: "doc.kml", data: kmlData)
        
        return FileWrapper(regularFileWithContents: zipData)
    }
    
    private func generateKMLContent() -> String {
        let radius = planet.meshConfiguration.shapeSettings.radius
        let resolution = planet.meshConfiguration.resolution
        let noiseLayerCount = planet.meshConfiguration.shapeSettings.noiseLayers.count
        
        // Generate color information from texture configuration - properly escape XML
        let colorInfo = planet.textureConfiguration.gradientPoints
            .map { "Color at \(String(format: "%.2f", $0.position)): \(xmlEscape($0.color.description))" }
            .joined(separator: ", ")
        
        // Escape planet name for XML
        let escapedPlanetName = xmlEscape(planet.name)
        
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(escapedPlanetName)</name>
            <description><![CDATA[
              Procedural Planet exported from ProceduralPlanets App
              
              Planet Properties:
              - Name: \(planet.name)
              - Radius: \(String(format: "%.3f", radius))
              - Mesh Resolution: \(resolution)
              - Noise Layers: \(noiseLayerCount)
              
              Texture Configuration:
              \(colorInfo)
              
              This planet was generated using procedural algorithms with noise-based terrain generation.
            ]]></description>
            <Placemark>
              <name>\(escapedPlanetName)</name>
              <description><![CDATA[A procedural planet with radius \(String(format: "%.3f", radius)) and \(noiseLayerCount) noise layers]]></description>
              <Point>
                <coordinates>0,0,0</coordinates>
              </Point>
              <ExtendedData>
                <Data name="type">
                  <value>ProceduralPlanet</value>
                </Data>
                <Data name="radius">
                  <value>\(radius)</value>
                </Data>
                <Data name="resolution">
                  <value>\(resolution)</value>
                </Data>
                <Data name="noiseLayerCount">
                  <value>\(noiseLayerCount)</value>
                </Data>
                <Data name="exportedFrom">
                  <value>ProceduralPlanets App</value>
                </Data>
              </ExtendedData>
            </Placemark>
          </Document>
        </kml>
        """
    }
    
    private func xmlEscape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
    
    private func createSimpleZip(filename: String, data: Data) throws -> Data {
        // Create a simple ZIP file containing just the KML
        // This is a minimal implementation - in production you'd use a proper ZIP library
        
        let filenameData = filename.data(using: .utf8)!
        let filenameLength = UInt16(filenameData.count)
        let fileSize = UInt32(data.count)
        
        var zipData = Data()
        
        // Local file header
        zipData.append(contentsOf: [0x50, 0x4B, 0x03, 0x04]) // Local file header signature
        zipData.append(contentsOf: [0x14, 0x00]) // Version needed to extract
        zipData.append(contentsOf: [0x00, 0x00]) // General purpose bit flag
        zipData.append(contentsOf: [0x00, 0x00]) // Compression method (stored)
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // File modification time & date
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // CRC-32 (simplified, should calculate)
        zipData.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        zipData.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        zipData.append(withUnsafeBytes(of: filenameLength.littleEndian) { Data($0) })
        zipData.append(contentsOf: [0x00, 0x00]) // Extra field length
        zipData.append(filenameData)
        zipData.append(data)
        
        // Central directory header
        let centralDirOffset = UInt32(zipData.count)
        zipData.append(contentsOf: [0x50, 0x4B, 0x01, 0x02]) // Central directory file header signature
        zipData.append(contentsOf: [0x14, 0x00]) // Version made by
        zipData.append(contentsOf: [0x14, 0x00]) // Version needed to extract
        zipData.append(contentsOf: [0x00, 0x00]) // General purpose bit flag
        zipData.append(contentsOf: [0x00, 0x00]) // Compression method
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // File modification time & date
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // CRC-32
        zipData.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        zipData.append(withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        zipData.append(withUnsafeBytes(of: filenameLength.littleEndian) { Data($0) })
        zipData.append(contentsOf: [0x00, 0x00]) // Extra field length
        zipData.append(contentsOf: [0x00, 0x00]) // File comment length
        zipData.append(contentsOf: [0x00, 0x00]) // Disk number start
        zipData.append(contentsOf: [0x00, 0x00]) // Internal file attributes
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // External file attributes
        zipData.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // Relative offset of local header
        zipData.append(filenameData)
        
        // End of central directory record
        let centralDirSize = UInt32(zipData.count) - centralDirOffset
        zipData.append(contentsOf: [0x50, 0x4B, 0x05, 0x06]) // End of central dir signature
        zipData.append(contentsOf: [0x00, 0x00]) // Number of this disk
        zipData.append(contentsOf: [0x00, 0x00]) // Number of disk with start of central directory
        zipData.append(contentsOf: [0x01, 0x00]) // Total number of entries in central directory on this disk
        zipData.append(contentsOf: [0x01, 0x00]) // Total number of entries in central directory
        zipData.append(withUnsafeBytes(of: centralDirSize.littleEndian) { Data($0) })
        zipData.append(withUnsafeBytes(of: centralDirOffset.littleEndian) { Data($0) })
        zipData.append(contentsOf: [0x00, 0x00]) // ZIP file comment length
        
        return zipData
    }
}

extension UTType {
    static var kmz: UTType {
        UTType(filenameExtension: "kmz") ?? UTType(filenameExtension: "zip") ?? UTType.data
    }
}
