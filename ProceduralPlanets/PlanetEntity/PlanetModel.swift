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
    
    // Store configurations as Data to avoid SIMD serialization issues
    @Attribute(.externalStorage)
    private var meshConfigurationData: Data?
    
    @Attribute(.externalStorage)
    private var textureConfigurationData: Data?
    
    @Attribute(.externalStorage)
    private var iceCapConfigurationData: Data?
    
    // Computed properties for easy access
    var meshConfiguration: MeshConfiguration? {
        get {
            guard !(meshConfigurationData?.isEmpty ?? true) else {
                // Return default configuration if data is empty
                return MeshConfiguration(resolution: 50, shapeSettings: ShapeSettings(radius: 1.0, noiseLayers: []))
            }
            do {
                return try JSONDecoder().decode(MeshConfiguration.self, from: meshConfigurationData ?? Data())
            } catch {
                print("Failed to decode mesh configuration: \(error)")
                return MeshConfiguration(resolution: 50, shapeSettings: ShapeSettings(radius: 1.0, noiseLayers: []))
            }
        }
        set {
            do {
                meshConfigurationData = try JSONEncoder().encode(newValue)
            } catch {
                print("Failed to encode mesh configuration: \(error)")
            }
        }
    }
    
    var textureConfiguration: TextureConfiguration? {
        get {
            guard !(textureConfigurationData?.isEmpty ?? true) else {
                // Return default configuration if data is empty
                return TextureConfiguration(gradientPoints: [])
            }
            do {
                return try JSONDecoder().decode(TextureConfiguration.self, from: textureConfigurationData ?? Data())
            } catch {
                print("Failed to decode texture configuration: \(error)")
                return TextureConfiguration(gradientPoints: [])
            }
        }
        set {
            do {
                textureConfigurationData = try JSONEncoder().encode(newValue)
            } catch {
                print("Failed to encode texture configuration: \(error)")
            }
        }
    }
    
    var iceCapConfiguration: IceCapConfiguration? {
        get {
            guard let data = iceCapConfigurationData else { return nil }
            do {
                return try JSONDecoder().decode(IceCapConfiguration.self, from: data)
            } catch {
                print("Failed to decode ice cap configuration: \(error)")
                return nil
            }
        }
        set {
            if let configuration = newValue {
                do {
                    iceCapConfigurationData = try JSONEncoder().encode(configuration)
                } catch {
                    print("Failed to encode ice cap configuration: \(error)")
                    iceCapConfigurationData = nil
                }
            } else {
                iceCapConfigurationData = nil
            }
        }
    }
    
    init(name: String, meshConfiguration: MeshConfiguration, textureConfiguration: TextureConfiguration, iceCapConfiguration: IceCapConfiguration? = nil) {
        self.name = name
        
        // Initialize data properties with encoded configurations
        do {
            self.meshConfigurationData = try JSONEncoder().encode(meshConfiguration)
            self.textureConfigurationData = try JSONEncoder().encode(textureConfiguration)
            
            if let iceCapConfig = iceCapConfiguration {
                self.iceCapConfigurationData = try JSONEncoder().encode(iceCapConfig)
            } else {
                self.iceCapConfigurationData = nil
            }
        } catch {
            print("Failed to encode configurations during initialization: \(error)")
            // Fallback to empty data - will use default values when accessed
            self.meshConfigurationData = Data()
            self.textureConfigurationData = Data()
            self.iceCapConfigurationData = nil
        }
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
    
    enum CodingKeys: String, CodingKey {
        case numberOfLayers
        case persistance
        case baseRoughness
        case strength
        case roughness
        case center
        case minValue
    }
    
    init(numberOfLayers: Int, persistance: Float, baseRoughness: Float, strength: Float, roughness: Float, center: SIMD3<Float>, minValue: Float) {
        self.numberOfLayers = numberOfLayers
        self.persistance = persistance
        self.baseRoughness = baseRoughness
        self.strength = strength
        self.roughness = roughness
        self.center = center
        self.minValue = minValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        numberOfLayers = try container.decode(Int.self, forKey: .numberOfLayers)
        persistance = try container.decode(Float.self, forKey: .persistance)
        baseRoughness = try container.decode(Float.self, forKey: .baseRoughness)
        strength = try container.decode(Float.self, forKey: .strength)
        roughness = try container.decode(Float.self, forKey: .roughness)
        minValue = try container.decode(Float.self, forKey: .minValue)
        
        // Decode SIMD3<Float> as array
        let centerArray = try container.decode([Float].self, forKey: .center)
        if centerArray.count == 3 {
            center = SIMD3<Float>(centerArray[0], centerArray[1], centerArray[2])
        } else {
            center = SIMD3<Float>(0, 0, 0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(numberOfLayers, forKey: .numberOfLayers)
        try container.encode(persistance, forKey: .persistance)
        try container.encode(baseRoughness, forKey: .baseRoughness)
        try container.encode(strength, forKey: .strength)
        try container.encode(roughness, forKey: .roughness)
        try container.encode(minValue, forKey: .minValue)
        
        // Encode SIMD3<Float> as array
        try container.encode([center.x, center.y, center.z], forKey: .center)
    }
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
        
        // Try to get cgColor, if it fails, create a resolved CGColor in sRGB space
        let cgColor: CGColor
        if let directCGColor = color.cgColor {
            cgColor = directCGColor
        } else {
            // Resolve the color by converting to sRGB color space
            let resolvedColor = color.resolve(in: EnvironmentValues())
            cgColor = CGColor(
                srgbRed: CGFloat(resolvedColor.red),
                green: CGFloat(resolvedColor.green),
                blue: CGFloat(resolvedColor.blue),
                alpha: CGFloat(resolvedColor.opacity)
            )
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
        
        let iceCapConfiguration = IceCapConfiguration(
            enabled: true,
            settings: .earthLike
        )
        
        return PlanetModel(
            name: "Sample Planet",
            meshConfiguration: meshConfiguration,
            textureConfiguration: textureConfiguration,
            iceCapConfiguration: iceCapConfiguration
        )
    }
}

// MARK: - Ice Cap Configuration

struct IceCapConfiguration: Equatable, Codable {
    
    var enabled: Bool
    var settings: IceCapSettings
    
    init(enabled: Bool = false, settings: IceCapSettings = .earthLike) {
        self.enabled = enabled
        self.settings = settings
    }
    
    init(from decoder: Decoder) throws {
        self.enabled = false
        self.settings = .earthLike
    }
    
    /// Default configuration with ice caps disabled
    static let disabled = IceCapConfiguration(enabled: false)
    
    /// Earth-like ice cap configuration
    static let earthLike = IceCapConfiguration(enabled: true, settings: .earthLike)
    
    /// Icy world configuration
    static let icyWorld = IceCapConfiguration(enabled: true, settings: .icyWorld)
    
    /// Desert world configuration (minimal ice)
    static let desert = IceCapConfiguration(enabled: true, settings: .desert)
    
}
