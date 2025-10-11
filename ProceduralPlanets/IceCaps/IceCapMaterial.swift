//
//  IceCapMaterial.swift
//  ProceduralPlanets
//
//  Created by Assistant on 9/27/25.
//

import Foundation
import RealityKit
import Combine
import SwiftUI
import simd

/// Manager for ice cap shader materials
@MainActor
class IceCapMaterial: ObservableObject {
    
    // MARK: - Properties
    
    @Published var settings: IceCapSettings {
        didSet {
            updateMaterial()
        }
    }
    
    private var shaderMaterial: ShaderGraphMaterial?
    private var isLoaded = false
    
    // MARK: - Initialization
    
    init(settings: IceCapSettings = .earthLike) {
        self.settings = settings
    }
    
    // MARK: - Material Loading
    
    /// Load the ice cap shader material from the USD file
    func loadMaterial() async throws {
        do {
            // Try different path formats to locate the USDA file
            var shaderGraphMaterial: ShaderGraphMaterial?
            
            // Try loading with various path formats
            let pathFormats = [
                "/IceCapMaterial",
                "IceCapMaterial",
                "/repo/IceCapMaterial",
                "/IceCapMaterial.usda"
            ]
            
            for path in pathFormats {
                do {
                    shaderGraphMaterial = try await ShaderGraphMaterial(
                        named: path,
                        from: "IceCapMaterial",
                        in: nil
                    )
                    if shaderGraphMaterial != nil {
                        print("Successfully loaded ice cap material from path: \(path)")
                        break
                    }
                } catch {
                    print("Failed to load from path \(path): \(error)")
                    // Continue trying other paths
                }
            }
            
            guard let material = shaderGraphMaterial else {
                throw IceCapMaterialError.materialLoadFailed(NSError(domain: "IceCapMaterial", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load ice cap material from any path"]))
            }
            
            self.shaderMaterial = material
            isLoaded = true
            await updateMaterial()
        } catch {
            print("Failed to load ice cap material: \(error)")
            throw IceCapMaterialError.materialLoadFailed(error)
        }
    }
    
    /// Update material parameters based on current settings
    private func updateMaterial() {
        guard let material = shaderMaterial, isLoaded else { 
            print("Cannot update material: Material not loaded or not initialized")
            return 
        }
        
        var updatedMaterial = material
        
        do {
            // Ice cap thresholds
            try updatedMaterial.setParameter(name: "northCapThreshold", value: .float(settings.northCapThreshold))
            try updatedMaterial.setParameter(name: "southCapThreshold", value: .float(settings.southCapThreshold))
            try updatedMaterial.setParameter(name: "falloffSharpness", value: .float(settings.falloffSharpness))
            
            // Elevation parameters - these might come from the mesh, but we set defaults
            try updatedMaterial.setParameter(name: "minElevation", value: .float(settings.minElevationForIce))
            try updatedMaterial.setParameter(name: "maxElevation", value: .float(settings.maxElevationForIce))
            
            // Climate parameters
            try updatedMaterial.setParameter(name: "globalTemperature", value: .float(settings.globalTemperature))
            
            // Ice appearance
//            try updatedMaterial.setParameter(name: "iceColor", value: x.float3(settings.iceColor))
            try updatedMaterial.setParameter(name: "iceRoughness", value: .float(settings.iceRoughness))
            try updatedMaterial.setParameter(name: "iceMetallic", value: .float(settings.iceMetallic))
            
            // Noise parameters
            try updatedMaterial.setParameter(name: "noiseScale", value: .float(settings.noiseScale))
            try updatedMaterial.setParameter(name: "noiseStrength", value: .float(settings.noiseStrength))
            
            print("Successfully updated ice cap material parameters")
            self.shaderMaterial = updatedMaterial
            
        } catch {
            print("Failed to update ice cap material parameters: \(error)")
            print("Parameter that failed: \(error)")
        }
    }
    
    /// Set base texture for the planet surface
    func setBaseTexture(_ texture: CGImage) throws {
        guard var material = shaderMaterial, isLoaded else {
            throw IceCapMaterialError.materialNotLoaded
        }
        
        let textureResource = try TextureResource(image: texture, options: .init(semantic: .color))
        try material.setParameter(name: "baseTexture", value: .textureResource(textureResource))
        self.shaderMaterial = material
    }
    
    /// Get the configured material for use in RealityKit
    func getMaterial() throws -> ShaderGraphMaterial {
        guard let material = shaderMaterial, isLoaded else {
            throw IceCapMaterialError.materialNotLoaded
        }
        return material
    }
    
    // MARK: - Convenience Methods
    
    /// Create a material configured for Earth-like ice caps
    static func earthLike() -> IceCapMaterial {
        return IceCapMaterial(settings: .earthLike)
    }
    
    /// Create a material configured for an icy world
    static func icyWorld() -> IceCapMaterial {
        return IceCapMaterial(settings: .icyWorld)
    }
    
    /// Create a material configured for a desert world
    static func desert() -> IceCapMaterial {
        return IceCapMaterial(settings: .desert)
    }
    
}

// MARK: - Error Handling

enum IceCapMaterialError: LocalizedError {
    case materialLoadFailed(Error)
    case materialNotLoaded
    case parameterSetFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .materialLoadFailed(let error):
            return "Failed to load ice cap material: \(error.localizedDescription)"
        case .materialNotLoaded:
            return "Ice cap material not loaded. Call loadMaterial() first."
        case .parameterSetFailed(let parameter):
            return "Failed to set parameter '\(parameter)' on ice cap material."
        }
    }
}

// MARK: - Integration with Existing Planet System

extension PlanetEntity {
    
    /// Update the planet with ice cap material
    func applyIceCapMaterial(_ iceCapMaterial: IceCapMaterial) async throws {
        let material = try iceCapMaterial.getMaterial()
        
        guard var modelComponent = self.modelComponent else {
            throw IceCapMaterialError.materialNotLoaded
        }
        
        // Replace existing materials with ice cap material
        modelComponent.materials = [material]
        self.components.set(modelComponent)
    }
    
    /// Apply ice cap material to the planet entity
    func applyIceCapMaterialWithElevation(
        _ iceCapMaterial: IceCapMaterial,
        baseElevationMin: Float,
        baseElevationMax: Float
    ) async throws {
        var material = try iceCapMaterial.getMaterial()
        
        // Set elevation range for proper ice placement
        try material.setParameter(name: "minElevation", value: .float(baseElevationMin))
        try material.setParameter(name: "maxElevation", value: .float(baseElevationMax))
        
        guard var modelComponent = self.modelComponent else {
            throw IceCapMaterialError.materialNotLoaded
        }
        
        // Replace existing materials with ice cap material
        modelComponent.materials = [material]
        self.components.set(modelComponent)
    }
    
}
