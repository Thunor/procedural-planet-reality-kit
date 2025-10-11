//
//  IceCapSettingsView.swift
//  ProceduralPlanets
//
//  Created by Assistant on 9/30/25.
//

import SwiftUI

struct IceCapSettingsView: View {
    @Binding var iceCapConfiguration: IceCapConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Enable Ice Caps", isOn: $iceCapConfiguration.enabled)
                .toggleStyle(.switch)
                .padding(.bottom, 8)
            
            if iceCapConfiguration.enabled {
                Divider()
                
                Text("Presets")
                    .font(.headline)
                
                HStack {
                    Button("Earth-like") {
                        iceCapConfiguration.settings = .earthLike
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Icy World") {
                        iceCapConfiguration.settings = .icyWorld
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Desert") {
                        iceCapConfiguration.settings = .desert
                    }
                    .buttonStyle(.bordered)
                }
                
                // NOTE: We shouldn't create a new material here.
                // Instead, we should be using a reference to the actual material being used by the planet.
                // For now, this is a temporary solution until we can properly fix the binding.
                let iceCapMaterial = IceCapMaterial(settings: iceCapConfiguration.settings)
                
                Divider()
                
                Group {
                    Text("Ice Cap Coverage")
                        .font(.headline)
                    
                    HStack {
                        Text("North Cap")
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.northCapThreshold },
                                set: { iceCapConfiguration.settings.northCapThreshold = $0 }
                            ),
                            in: 0.0...1.0
                        )
                        Text(String(format: "%.2f", iceCapMaterial.settings.northCapThreshold))
                            .frame(width: 40)
                    }
                    
                    HStack {
                        Text("South Cap")
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.southCapThreshold },
                                set: { iceCapConfiguration.settings.southCapThreshold = $0 }
                            ),
                            in: -1.0...0.0
                        )
                        Text(String(format: "%.2f", iceCapMaterial.settings.southCapThreshold))
                            .frame(width: 40)
                    }
                    
                    HStack {
                        Text("Edge Sharpness")
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.falloffSharpness },
                                set: { iceCapConfiguration.settings.falloffSharpness = $0 }
                            ),
                            in: 1.0...10.0
                        )
                        Text(String(format: "%.1f", iceCapMaterial.settings.falloffSharpness))
                            .frame(width: 40)
                    }
                }
                
                Divider()
                
                Group {
                    Text("Global Climate")
                        .font(.headline)
                    
                    HStack {
                        Text("Global Temperature")
                        Slider(
                            value: Binding(
                                get: { iceCapMaterial.settings.globalTemperature },
                                set: { iceCapConfiguration.settings.globalTemperature = $0 }
                            ),
                            in: -1.0...1.0
                        )
                        Text(String(format: "%.1f", iceCapMaterial.settings.globalTemperature))
                            .frame(width: 40)
                    }
                }
            }
        }
        .padding()
    }
}
