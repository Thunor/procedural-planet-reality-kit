//
//  ShapeGenerator.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 8/20/24.
//

import Foundation
import RealityKit

struct ShapeGenerator {
    
    var shapeSettings: ShapeSettings
    var noiseFilters: [NoiseFilter]
    var craterFilters: [CraterFilter]
    var elevationMinMax: MinMax
    
    init(shapeSettings: ShapeSettings) {
        self.shapeSettings = shapeSettings
        self.noiseFilters = []
        self.craterFilters = []
        self.elevationMinMax = MinMax()
        
        // Initialize filters based on layer type
        for layer in shapeSettings.noiseLayers {
            switch layer.layerType {
            case .standard:
                noiseFilters.append(NoiseFilter(noiseSettings: layer.noiseSettings))
                craterFilters.append(CraterFilter(craterSettings: CraterSettings())) // Dummy
            case .craters:
                noiseFilters.append(NoiseFilter(noiseSettings: layer.noiseSettings)) // Dummy
                if let craterSettings = layer.craterSettings {
                    craterFilters.append(CraterFilter(craterSettings: craterSettings))
                } else {
                    craterFilters.append(CraterFilter(craterSettings: CraterSettings()))
                }
            }
        }
    }
    
    func calculatePointOnPlanet(pointOnUnitSphere: SIMD3<Float>) -> SIMD3<Float> {
        var firstLayerValue: Float = 0
        var elevation: Float = 0
        
        // Process first layer
        if !shapeSettings.noiseLayers.isEmpty && shapeSettings.noiseLayers[0].enabled {
            switch shapeSettings.noiseLayers[0].layerType {
            case .standard:
                if !noiseFilters.isEmpty {
                    firstLayerValue = noiseFilters[0].evaluatePoint(pointOnUnitSphere)
                    elevation = firstLayerValue
                }
            case .craters:
                if !craterFilters.isEmpty {
                    firstLayerValue = craterFilters[0].evaluatePoint(pointOnUnitSphere)
                    elevation = firstLayerValue
                }
            }
        }
        
        // Process remaining layers
        if shapeSettings.noiseLayers.count >= 1 {
            
            for i in 1..<shapeSettings.noiseLayers.count {
                if shapeSettings.noiseLayers[i].enabled {
                    let mask = shapeSettings.noiseLayers[i].useFirstLayerAsMask ? firstLayerValue : 1
                    var layerValue: Float = 0
                    
                    switch shapeSettings.noiseLayers[i].layerType {
                        case .standard:
                            if i < noiseFilters.count {
                                layerValue = noiseFilters[i].evaluatePoint(pointOnUnitSphere)
                            }
                        case .craters:
                            if i < craterFilters.count {
                                layerValue = craterFilters[i].evaluatePoint(pointOnUnitSphere)
                            }
                    }
                    
                    elevation += layerValue * mask
                }
            }
        }
        
        elevation = shapeSettings.radius * (1 + elevation)
        elevationMinMax.addValue(elevation)
        
        return pointOnUnitSphere * elevation
    }
    
}
