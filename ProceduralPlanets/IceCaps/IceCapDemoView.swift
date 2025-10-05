//
//  IceCapDemoView.swift
//  ProceduralPlanets
//
//  Created by Assistant on 9/27/25.
//

import SwiftUI
import RealityKit

/// Demo view showcasing ice cap functionality
struct IceCapDemoView: View {
    
    @State private var iceCapMaterial = IceCapMaterial.earthLike()
    @State private var iceCapConfiguration = IceCapConfiguration.earthLike
    @State private var planetEntity: PlanetEntity?
    @State private var isLoading = false
    @State private var selectedPreset: IceCapPreset = .earthLike
    
    private enum IceCapPreset: String, CaseIterable {
        case earthLike = "Earth-like"
        case icyWorld = "Icy World"
        case desert = "Desert Planet"
        
        var settings: IceCapSettings {
            switch self {
            case .earthLike: return .earthLike
            case .icyWorld: return .icyWorld
            case .desert: return .desert
            }
        }
        
        var description: String {
            switch self {
            case .earthLike: return "Moderate ice caps at the poles with elevation dependency"
            case .icyWorld: return "Extensive ice coverage with thick polar caps"
            case .desert: return "Minimal ice caps only at high elevations"
            }
        }
    }
    
    var body: some View {
        HSplitView {
            // 3D View
            VStack {
                if isLoading {
                    VStack {
                        ProgressView("Loading Ice Cap Shader...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Compiling shader materials...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RealityView { content in
                        // Add existing planet entity if available
                        if let planet = planetEntity {
                            content.add(planet)
                        }
                    } update: { content in
                        // Planet updates are handled through the ObservableObject pattern
                        // The material will automatically update when settings change
                    }
                    .realityViewCameraControls(.orbit)
                }
                
                // Preset Selection
                HStack {
                    Text("Preset:")
                        .font(.headline)
                    
                    Picker("Ice Cap Preset", selection: $selectedPreset) {
                        ForEach(IceCapPreset.allCases, id: \.self) { preset in
                            Text(preset.rawValue)
                                .tag(preset)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedPreset) { _, newPreset in
                        applyPreset(newPreset)
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor))
            }
            
            // Controls
            VStack(alignment: .leading) {
                Text("Ice Cap Configuration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text(selectedPreset.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                IceCapSettingsView(iceCapConfiguration: $iceCapConfiguration)
            }
            .frame(minWidth: 350, maxWidth: 450)
            .padding()
        }
        .navigationTitle("Ice Cap Shader Demo")
        .onChange(of: iceCapConfiguration.settings) { _, newSettings in
            iceCapMaterial.settings = newSettings
        }
        .task {
            await loadIceCapMaterial()
        }
    }
    
    // MARK: - Methods
    
    @MainActor
    private func loadIceCapMaterial() async {
        isLoading = true
        
        do {
            // Ensure configuration settings match the selected preset
            iceCapConfiguration.settings = selectedPreset.settings
            iceCapMaterial.settings = selectedPreset.settings
            
            try await iceCapMaterial.loadMaterial()
            await createPlanetEntity()
            isLoading = false
        } catch {
            print("Failed to load ice cap material: \(error)")
            isLoading = false
        }
    }
    
    @MainActor
    private func createPlanetEntity() async {
        do {
            // Create sample planet configuration
            let meshConfig = createSampleMeshConfiguration()
            
            let planet = try await PlanetEntity(
                meshConfiguration: meshConfig,
                imageTexture: nil,
                iceCapConfiguration: iceCapConfiguration
            )
            
            // Position and scale the planet
            planet.transform.translation = SIMD3<Float>(0, 0, -2)
            planet.transform.scale = SIMD3<Float>(0.8, 0.8, 0.8)
            
            self.planetEntity = planet
            
        } catch {
            print("Failed to create planet with ice caps: \(error)")
        }
    }
    
    private func applyPreset(_ preset: IceCapPreset) {
        iceCapMaterial.settings = preset.settings
        iceCapConfiguration.settings = preset.settings
        iceCapConfiguration.enabled = true
        
        // Recreate the planet with new settings
        Task {
            await createPlanetEntity()
        }
    }
    
    private func createSampleMeshConfiguration() -> MeshConfiguration {
        let baseNoiseLayer = NoiseLayer(
            enabled: true,
            useFirstLayerAsMask: false,
            noiseSettings: NoiseSettings(
                numberOfLayers: 4,
                persistance: 0.5,
                baseRoughness: 1.0,
                strength: 0.3,
                roughness: 2.0,
                center: SIMD3<Float>(0, 0, 0),
                minValue: 0.2
            ),
            layerType: .standard
        )
        
        let detailNoiseLayer = NoiseLayer(
            enabled: true,
            useFirstLayerAsMask: false,
            noiseSettings: NoiseSettings(
                numberOfLayers: 3,
                persistance: 0.5,
                baseRoughness: 2.0,
                strength: 0.1,
                roughness: 2.5,
                center: SIMD3<Float>(0, 0, 0),
                minValue: 0.0
            ),
            layerType: .standard
        )
        
        let shapeSettings = ShapeSettings(
            radius: 1.0,
            noiseLayers: [baseNoiseLayer, detailNoiseLayer]
        )
        
        return MeshConfiguration(
            resolution: 100, // Higher resolution for better ice cap detail
            shapeSettings: shapeSettings
        )
    }
    
}

// MARK: - Advanced Ice Cap Controls

struct AdvancedIceCapControls: View {
    
    @ObservedObject var iceCapMaterial: IceCapMaterial
    
    var body: some View {
        GroupBox("Advanced Controls") {
            VStack(alignment: .leading, spacing: 12) {
                
                // Seasonal Controls
                VStack(alignment: .leading) {
                    Text("Seasonal Variation")
                        .font(.headline)
                    
                    HStack {
                        Text("Seasonal Strength")
                        Spacer()
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.seasonalVariation },
                                set: { iceCapMaterial.settings.seasonalVariation = $0 }
                            ),
                            in: 0...1
                        )
                        .frame(width: 120)
                        Text("\(iceCapMaterial.settings.seasonalVariation, specifier: "%.2f")")
                            .frame(width: 40)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Season Angle")
                        Spacer()
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.seasonAngle },
                                set: { iceCapMaterial.settings.seasonAngle = $0 }
                            ),
                            in: 0...Float.pi * 2
                        )
                        .frame(width: 120)
                        Text("\(iceCapMaterial.settings.seasonAngle * 180 / Float.pi, specifier: "%.0f")°")
                            .frame(width: 40)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Advanced Features
                VStack(alignment: .leading) {
                    Text("Advanced Features")
                        .font(.headline)
                    
                    Toggle("Ice Flow Patterns", isOn: Binding(
                        get: { iceCapMaterial.settings.enableIceFlow },
                        set: { iceCapMaterial.settings.enableIceFlow = $0 }
                    ))
                    
                    if iceCapMaterial.settings.enableIceFlow {
                        HStack {
                            Text("Flow Scale")
                            Spacer()
                            Slider(
                                value: Binding(
                                    get: { iceCapMaterial.settings.iceFlowScale },
                                    set: { iceCapMaterial.settings.iceFlowScale = $0 }
                                ),
                                in: 0.5...10
                            )
                            .frame(width: 120)
                            Text("\(iceCapMaterial.settings.iceFlowScale, specifier: "%.1f")")
                                .frame(width: 40)
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Cracks Intensity")
                            Spacer()
                            Slider(
                                value: Binding(
                                    get: { iceCapMaterial.settings.cracksIntensity },
                                    set: { iceCapMaterial.settings.cracksIntensity = $0 }
                                ),
                                in: 0...1
                            )
                            .frame(width: 120)
                            Text("\(iceCapMaterial.settings.cracksIntensity, specifier: "%.2f")")
                                .frame(width: 40)
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Material Properties
                VStack(alignment: .leading) {
                    Text("Material Properties")
                        .font(.headline)
                    
                    HStack {
                        Text("Ice Thickness")
                        Spacer()
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.iceThickness },
                                set: { iceCapMaterial.settings.iceThickness = $0 }
                            ),
                            in: 0.001...0.1
                        )
                        .frame(width: 120)
                        Text("\(iceCapMaterial.settings.iceThickness, specifier: "%.3f")")
                            .frame(width: 40)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Subsurface Scattering")
                        Spacer()
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.iceSubsurface },
                                set: { iceCapMaterial.settings.iceSubsurface = $0 }
                            ),
                            in: 0...1
                        )
                        .frame(width: 120)
                        Text("\(iceCapMaterial.settings.iceSubsurface, specifier: "%.2f")")
                            .frame(width: 40)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        IceCapDemoView()
    }
    .frame(width: 1200, height: 800)
}
