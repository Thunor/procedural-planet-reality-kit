//
//  PlanetConfiguration.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 8/15/24.
//

import Foundation
import SwiftData
import SwiftUI
import CoreGraphics
import CoreImage

@Model
class PlanetModel {

    var name: String
    var meshConfiguration: MeshConfiguration
    var textureConfiguration: TextureConfiguration
    
    init(name: String, meshConfiguration: MeshConfiguration, textureConfiguration: TextureConfiguration) {
        self.meshConfiguration = meshConfiguration
        self.textureConfiguration = textureConfiguration
        self.name = name
    }
    
}

struct MeshConfiguration: Equatable, Codable {
    
    let resolution: Int
    var shapeSettings: ShapeSettings
    
    init(resolution: Int, shapeSettings: ShapeSettings) {
        self.resolution = resolution
        self.shapeSettings = shapeSettings
    }
    
}

struct ShapeSettings: Equatable, Codable {
    
    var radius: Float
    var noiseLayers: [NoiseLayer]
    
}

struct NoiseLayer: Equatable, Hashable, Codable {
    var enabled = true
    var useFirstLayerAsMask = true
    var noiseSettings: NoiseSettings
    var craterSettings: CraterSettings?
    var layerType: NoiseLayerType = .standard
    
    enum CodingKeys: String, CodingKey {
        case enabled
        case useFirstLayerAsMask
        case noiseSettings
        case craterSettings
        case layerType
    }
    
    init(enabled: Bool = true, useFirstLayerAsMask: Bool = true, noiseSettings: NoiseSettings, craterSettings: CraterSettings? = nil, layerType: NoiseLayerType = .standard) {
        self.enabled = enabled
        self.useFirstLayerAsMask = useFirstLayerAsMask
        self.noiseSettings = noiseSettings
        self.craterSettings = craterSettings
        self.layerType = layerType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        useFirstLayerAsMask = try container.decodeIfPresent(Bool.self, forKey: .useFirstLayerAsMask) ?? true
        noiseSettings = try container.decode(NoiseSettings.self, forKey: .noiseSettings)
        craterSettings = try container.decodeIfPresent(CraterSettings.self, forKey: .craterSettings)
        // Use decodeIfPresent to handle missing layerType in older data
        layerType = try container.decodeIfPresent(NoiseLayerType.self, forKey: .layerType) ?? .standard
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(useFirstLayerAsMask, forKey: .useFirstLayerAsMask)
        try container.encode(noiseSettings, forKey: .noiseSettings)
        try container.encodeIfPresent(craterSettings, forKey: .craterSettings)
        try container.encode(layerType, forKey: .layerType)
    }
}

enum NoiseLayerType: String, CaseIterable, Codable {
    case standard = "Standard"
    case craters = "Craters"
    
    var displayName: String {
        return self.rawValue
    }
}

struct NoiseSettings: Equatable, Hashable, Codable {
    var numberOfLayers: Int
    var persistance: Float
    var baseRoughness: Float
    var strength: Float
    var roughness: Float
    var center: SIMD3<Float>
    var minValue: Float
}

struct CraterSettings: Equatable, Hashable, Codable {
    var craterCount: Int = 50
    var minRadius: Float = 0.02
    var maxRadius: Float = 0.15
    var rimHeight: Float = 0.3
    var rimWidth: Float = 0.2
    var depth: Float = 0.5
    var randomSeed: UInt32 = 12345
    var distribution: CraterDistribution = .uniform
    var fadeDistance: Float = 0.8
}

enum CraterDistribution: String, CaseIterable, Codable {
    case uniform = "Uniform"
    case clustered = "Clustered"
    case polar = "Polar Regions"
    
    var displayName: String {
        return self.rawValue
    }
}

struct TextureConfiguration: Codable {
    var gradientPoints: [GradientPoint]
}

struct GradientPoint: Identifiable, Codable {
    
    let id: UUID
    
    var color: Color
    var position: Float
    
    enum CodingKeys: String, CodingKey {
        case id
        case color
        case position
    }
    
    init(color: Color, position: Float) {
        self.id = UUID()
        self.color = color
        self.position = position
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        position = try container.decode(Float.self, forKey: .position)
        
        let codableColor = try container.decode(CodableColor.self, forKey: .color)
        color = Color(cgColor: codableColor.cgColor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        
        guard let cgColor = color.cgColor else {
            throw CodingError.wrongColor
        }
        let codableColor = CodableColor(cgColor: cgColor)
        try container.encode(codableColor, forKey: .color)
    }
    
}

struct CodableColor: Codable {
    
    let cgColor: CGColor
    
    enum CodingKeys: String, CodingKey {
        case colorSpace
        case components
    }
    
    init(cgColor: CGColor) {
        self.cgColor = cgColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorSpace = try container.decode(String.self, forKey: .colorSpace)
        let components = try container.decode([CGFloat].self, forKey: .components)
        
        guard
            let cgColorSpace = CGColorSpace(name: colorSpace as CFString),
            let cgColor = CGColor(
                colorSpace: cgColorSpace, components: components
            )
        else {
            throw CodingError.wrongData
        }
        
        self.cgColor = cgColor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard
            let colorSpace = cgColor.colorSpace?.name,
            let components = cgColor.components
        else {
            throw CodingError.wrongData
        }
              
        try container.encode(colorSpace as String, forKey: .colorSpace)
        try container.encode(components, forKey: .components)
    }
    
}

enum CodingError: Error {
    case wrongColor
    case wrongData
}

extension PlanetModel {
    static func samplePlanet() -> PlanetModel {
        let baseNoiseLayer = NoiseLayer(
            enabled: true,
            useFirstLayerAsMask: true,
            noiseSettings: NoiseSettings(
                numberOfLayers: 4,
                persistance: 0.5,
                baseRoughness: 1.0,
                strength: 0.1,
                roughness: 2.0,
                center: SIMD3<Float>(0, 0, 0),
                minValue: 0.5
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
                strength: 0.05,
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
        
        let meshConfiguration = MeshConfiguration(
            resolution: 50,
            shapeSettings: shapeSettings
        )
        
        let textureConfiguration = TextureConfiguration(
            gradientPoints: [
                GradientPoint(color: .blue, position: 0.0),
                GradientPoint(color: .green, position: 0.3),
                GradientPoint(color: .brown, position: 0.6),
                GradientPoint(color: .white, position: 1.0)
            ]
        )
        
        return PlanetModel(
            name: "Sample Planet",
            meshConfiguration: meshConfiguration,
            textureConfiguration: textureConfiguration
        )
    }
}
