//
//  PlanetEntity.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 7/16/24.
//

import Foundation
import RealityKit
import Combine
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
class PlanetEntity: Entity {
    
    private var iceCapMaterial: IceCapMaterial?
    
    init(meshConfiguration: MeshConfiguration, imageTexture: CGImage?, iceCapConfiguration: IceCapConfiguration? = nil) async throws {
        super.init()
        
        // Initialize ice cap material if enabled
        if let iceCapConfig = iceCapConfiguration, iceCapConfig.enabled {
            let iceCapMat = IceCapMaterial(settings: iceCapConfig.settings)
            try await iceCapMat.loadMaterial()
            self.iceCapMaterial = iceCapMat
        }
        
        try await self.updatePlanetConfig(meshConfiguration: meshConfiguration, iceCapConfiguration: iceCapConfiguration)
        
        if let imageTexture {
            self.updateImageTexture(imageTexture)
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func updatePlanetConfig(meshConfiguration: MeshConfiguration, iceCapConfiguration: IceCapConfiguration? = nil) async throws {
        let shapeGenerator = ShapeGenerator(shapeSettings: meshConfiguration.shapeSettings)
        let meshResource = try await createMeshResource(resolution: meshConfiguration.resolution,
                                                        shapeGenerator: shapeGenerator)
        
        let material: RealityKit.Material
        
        // Use ice cap material if enabled, otherwise use default material
        if let iceCapConfig = iceCapConfiguration, iceCapConfig.enabled, let iceCapMat = self.iceCapMaterial {
            material = try await self.createHybridMaterial(
                baseElevationMin: shapeGenerator.elevationMinMax.min, 
                baseElevationMax: shapeGenerator.elevationMinMax.max, 
                iceCapMaterial: iceCapMat
            )
        } else {
            material = await self.createMaterial(
                elevationMin: shapeGenerator.elevationMinMax.min, 
                elevationMax: shapeGenerator.elevationMinMax.max
            )
        }
        
        let modelComponent = ModelComponent(mesh: meshResource, materials: [material])
        self.components.set(modelComponent)
    }
    
    func updateImageTexture(_ texture: CGImage) {
        guard var modelComponent = self.modelComponent else { return }
        
        // Update ice cap material if it exists
        if let iceCapMat = self.iceCapMaterial {
            do {
                try iceCapMat.setBaseTexture(texture)
                let material = try iceCapMat.getMaterial()
                modelComponent.materials = [material]
                self.components.set(modelComponent)
                return
            } catch {
                print("Failed to update ice cap texture: \(error)")
                // Fall back to regular material update
            }
        }
        
        // Original texture update for non-ice cap materials
        guard var material = modelComponent.materials.first as? ShaderGraphMaterial else { return }
        let textureResource = try! TextureResource(image: texture, options: .init(semantic: .color))
        try! material.setParameter(name: "texture", value: .textureResource(textureResource))
        modelComponent.materials = [material]
        self.components.set(modelComponent)
    }
    
    private func createMeshResource(resolution: Int, shapeGenerator: ShapeGenerator) async throws -> MeshResource {
        let directions: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1, 0),   // up
            SIMD3<Float>(0, -1, 0),  // down
            SIMD3<Float>(-1, 0, 0),  // left
            SIMD3<Float>(1, 0, 0),   // right
            SIMD3<Float>(0, 0, 1),   // forward
            SIMD3<Float>(0, 0, -1)   // back
        ]
        
        let faceGenerator = TerrainFaceGenerator(shapeGenerator: shapeGenerator)
        let meshDescriptors = directions.map({ faceGenerator.constructMesh(resolution: resolution, localUp: $0) })
        return try await MeshResource(from: meshDescriptors)
    }
    
    private func createMaterial(elevationMin: Float, elevationMax: Float) async -> ShaderGraphMaterial {
        
        var customMaterial = try! await ShaderGraphMaterial(named: "/Root/MyMaterial/MyMaterial",
                                                            from: "Immersive",
                                                            in: nil)
        
        try! customMaterial.setParameter(name: "min", value: .float(elevationMin))
        try! customMaterial.setParameter(name: "max", value: .float(elevationMax))
        
        return customMaterial
    }
    
    private func createHybridMaterial(baseElevationMin: Float, baseElevationMax: Float, iceCapMaterial: IceCapMaterial) async throws -> RealityKit.Material {
        // Get the ice cap material from the IceCapMaterial instance and configure it with elevation data
        var material = try iceCapMaterial.getMaterial()
        
        // Set elevation parameters for proper ice placement
        try material.setParameter(name: "minElevation", value: .float(baseElevationMin))
        try material.setParameter(name: "maxElevation", value: .float(baseElevationMax))
        
        // Also set the base material parameters for consistency
        try material.setParameter(name: "min", value: .float(baseElevationMin))
        try material.setParameter(name: "max", value: .float(baseElevationMax))
        
        return material
    }
    
    
}

extension Entity {
    
    var modelComponent: ModelComponent? {
        return self.components.first(where: { $0 is ModelComponent }) as? ModelComponent
    }
    
}
