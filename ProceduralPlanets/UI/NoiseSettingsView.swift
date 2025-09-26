import Foundation
import SwiftUI

struct NoiseSettingsView: View {
    
    @Binding var noiseLayer: NoiseLayer
    
    init(noiseLayer: Binding<NoiseLayer>) {
        _noiseLayer = noiseLayer
    }
    
    var body: some View {
        VStack {
            // Layer type picker
            HStack {
                Text("Layer Type")
                    .padding(.trailing, 20)
                Picker("Layer Type", selection: $noiseLayer.layerType) {
                    ForEach(NoiseLayerType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: noiseLayer.layerType) { _, newType in
                    updateLayerForType(newType)
                }
            }
            .padding(.bottom, 10)
            
            switch noiseLayer.layerType {
            case .standard:
                standardNoiseSettings
            case .craters:
                craterSettings
            }
        }
    }
    
    @ViewBuilder
    private var standardNoiseSettings: some View {
        HStack {
            Text("Strength \(noiseLayer.noiseSettings.strength, specifier: "%.2f")")
                .padding(.trailing, 20)
            Slider(value: $noiseLayer.noiseSettings.strength, in: 0...2)
        }
        HStack {
            Text("Base Roughness \(noiseLayer.noiseSettings.baseRoughness, specifier: "%.2f")")
                .padding(.trailing, 20)
            Slider(value: $noiseLayer.noiseSettings.baseRoughness, in: 0...5)
        }
        HStack {
            Text("Roughness \(noiseLayer.noiseSettings.roughness, specifier: "%.2f")")
                .padding(.trailing, 20)
            Slider(value: $noiseLayer.noiseSettings.roughness, in: 0...5)
        }
        HStack {
            Text("Number Of Layers \(noiseLayer.noiseSettings.numberOfLayers)")
                .padding(.trailing, 20)
            Slider(value: Binding(
                get: { Double(noiseLayer.noiseSettings.numberOfLayers) },
                set: { noiseLayer.noiseSettings.numberOfLayers = Int($0.rounded()) }
            ), in: 0...10, step: 1.0)
        }
        HStack {
            Text("Persistance \(noiseLayer.noiseSettings.persistance, specifier: "%.2f")")
                .padding(.trailing, 20)
            Slider(value: $noiseLayer.noiseSettings.persistance, in: 0...1)
        }
        HStack {
            Text("Min Value \(noiseLayer.noiseSettings.minValue, specifier: "%.2f")")
                .padding(.trailing, 20)
            Slider(value: $noiseLayer.noiseSettings.minValue, in: 0...2)
        }
        VStack {
            Text("Center")
            HStack {
                Text("X")
                Slider(value: $noiseLayer.noiseSettings.center.x, in: -1...1)
            }
            HStack {
                Text("Y")
                Slider(value: $noiseLayer.noiseSettings.center.y, in: -1...1)
            }
            HStack {
                Text("Z")
                Slider(value: $noiseLayer.noiseSettings.center.z, in: -1...1)
            }
        }
    }
    
    @ViewBuilder
    private var craterSettings: some View {
        if let craterSettings = noiseLayer.craterSettings {
            CraterSettingsView(craterSettings: Binding(
                get: { craterSettings },
                set: { noiseLayer.craterSettings = $0 }
            ))
        }
    }
    
    private func updateLayerForType(_ type: NoiseLayerType) {
        switch type {
        case .standard:
            noiseLayer.craterSettings = nil
        case .craters:
            if noiseLayer.craterSettings == nil {
                noiseLayer.craterSettings = CraterSettings()
                // Adjust noise settings for crater generation
                noiseLayer.noiseSettings.strength = 0.3
                noiseLayer.noiseSettings.numberOfLayers = 1
            }
        }
    }
}

struct CraterSettingsView: View {
    @Binding var craterSettings: CraterSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Crater Configuration")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                Text("Crater Count: \(craterSettings.craterCount)")
                    .frame(width: 140, alignment: .leading)
                Slider(value: Binding(
                    get: { Double(craterSettings.craterCount) },
                    set: { craterSettings.craterCount = Int($0.rounded()) }
                ), in: 5...200, step: 1.0)
            }
            
            HStack {
                Text("Min Radius: \(craterSettings.minRadius, specifier: "%.3f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.minRadius, in: 0.005...0.1)
            }
            
            HStack {
                Text("Max Radius: \(craterSettings.maxRadius, specifier: "%.3f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.maxRadius, in: 0.05...0.3)
            }
            
            HStack {
                Text("Rim Height: \(craterSettings.rimHeight, specifier: "%.2f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.rimHeight, in: 0.0...1.0)
            }
            
            HStack {
                Text("Rim Width: \(craterSettings.rimWidth, specifier: "%.2f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.rimWidth, in: 0.1...0.5)
            }
            
            HStack {
                Text("Depth: \(craterSettings.depth, specifier: "%.2f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.depth, in: 0.1...2.0)
            }
            
            HStack {
                Text("Distribution:")
                    .frame(width: 100, alignment: .leading)
                Picker("Distribution", selection: $craterSettings.distribution) {
                    ForEach(CraterDistribution.allCases, id: \.self) { dist in
                        Text(dist.displayName).tag(dist)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack {
                Text("Random Seed: \(craterSettings.randomSeed)")
                    .frame(width: 140, alignment: .leading)
                Slider(value: Binding(
                    get: { Double(craterSettings.randomSeed) },
                    set: { craterSettings.randomSeed = UInt32($0.rounded()) }
                ), in: 0...99999, step: 1.0)
            }
            
            HStack {
                Text("Fade Distance: \(craterSettings.fadeDistance, specifier: "%.2f")")
                    .frame(width: 140, alignment: .leading)
                Slider(value: $craterSettings.fadeDistance, in: 0.5...2.0)
            }
            
            Button("Randomize Seed") {
                craterSettings.randomSeed = UInt32.random(in: 0...99999)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
