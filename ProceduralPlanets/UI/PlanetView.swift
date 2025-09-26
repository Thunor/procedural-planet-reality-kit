//
//  ContentView.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 7/15/24.
//

import SwiftUI
import RealityKit

struct PlanetView: View {
    
    var viewModel: PlanetEditorViewModel
    
    let root = Entity()
    
    @State private var planetEntity: PlanetEntity?
    @State private var rotationTimer: Timer?
    
    var body: some View {
        RealityView { content in
            
            content.add(root)
            
            // Add ambient lighting
            let ambientLight = DirectionalLightComponent(
                color: .white,
                intensity: 1500,
                isRealWorldProxy: false
            )
            let lightEntity = Entity()
            lightEntity.components.set(ambientLight)
            lightEntity.transform.rotation = simd_quatf(angle: .pi / 4, axis: [1, -1, 0])
            root.addChild(lightEntity)
            
            // Add another light from different angle
            let fillLight = DirectionalLightComponent(
                color: .white,
                intensity: 800,
                isRealWorldProxy: false
            )
            let fillLightEntity = Entity()
            fillLightEntity.components.set(fillLight)
            fillLightEntity.transform.rotation = simd_quatf(angle: -.pi / 3, axis: [-1, 1, 0])
            root.addChild(fillLightEntity)
            
            let planet = try! await PlanetEntity(meshConfiguration: viewModel.meshConfiguration,
                                                 imageTexture: viewModel.textureImage)
            self.planetEntity = planet
            
            // Scale the planet based on its radius for consistent library view size
            let baseScale: Float = 4.0
            let targetRadius: Float = 0.15 // Reference radius for scaling
            let currentRadius = viewModel.meshConfiguration.shapeSettings.radius
            let dynamicScale = baseScale * (targetRadius / currentRadius)
            planet.transform.scale = SIMD3<Float>(dynamicScale, dynamicScale, dynamicScale)
            
            root.addChild(planet)
            
            // Start rotation timer
            startRotationTimer()
            
        } update: { content in
            // Update block - camera positioning is handled by orbit controls
        }
        .onChange(of: self.viewModel.meshConfiguration) { _, newValue in
            Task {
                try! await self.planetEntity?.updatePlanetConfig(meshConfiguration: newValue)
                if let image = self.viewModel.textureImage {
                    self.planetEntity?.updateImageTexture(image)
                }
                
                // Update scale when radius changes
                if let planetEntity = self.planetEntity {
                    let baseScale: Float = 4.0
                    let targetRadius: Float = 0.15 // Reference radius for scaling
                    let currentRadius = newValue.shapeSettings.radius
                    let dynamicScale = baseScale * (targetRadius / currentRadius)
                    planetEntity.transform.scale = SIMD3<Float>(dynamicScale, dynamicScale, dynamicScale)
                }
            }
        }
        .onChange(of: self.viewModel.textureImage) { _, newValue in
            if let newValue {
                self.planetEntity?.updateImageTexture(newValue)
            }
        }
        .realityViewCameraControls(.orbit)
        .onDisappear {
            stopRotationTimer()
        }
    }
    
    private func startRotationTimer() {
        stopRotationTimer() // Stop any existing timer
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            guard let planetEntity = planetEntity else { return }
            
            // Rotate 1.8 degrees per second (360 degrees in 200 seconds)
            let rotationSpeed: Float = 0.003141593 // 1.8 degrees in radians per second at 60fps
            let currentRotation = planetEntity.transform.rotation
            let yRotation = simd_quatf(angle: rotationSpeed, axis: [0, 1, 0])
            planetEntity.transform.rotation = currentRotation * yRotation
        }
    }
    
    private func stopRotationTimer() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }

}
