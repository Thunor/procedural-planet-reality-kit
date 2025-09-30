//
//  IceCapSettings.swift
//  ProceduralPlanets
//
//  Created by Assistant on 9/27/25.
//

import Foundation
import SwiftUI
import simd

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Configuration settings for procedural ice caps on planets
struct IceCapSettings: Equatable, Codable {
    
    // MARK: - Ice Cap Coverage
    
    /// Latitude threshold for northern ice cap (0.0 = equator, 1.0 = north pole)
    var northCapThreshold: Float = 0.7
    
    /// Latitude threshold for southern ice cap (0.0 = equator, -1.0 = south pole)
    var southCapThreshold: Float = -0.7
    
    /// Falloff rate for ice cap edges (higher values = sharper edges)
    var falloffSharpness: Float = 2.0
    
    // MARK: - Elevation Dependencies
    
    /// Enable elevation-based ice coverage
    var useElevationMask: Bool = true
    
    /// Minimum elevation for ice formation (normalized 0-1)
    var minElevationForIce: Float = 0.3
    
    /// Maximum elevation where ice always forms (normalized 0-1)
    var maxElevationForIce: Float = 0.8
    
    // MARK: - Ice Properties
    
    /// Base ice thickness
    var iceThickness: Float = 0.02
    
    /// Ice color (base albedo)
    var iceColor: SIMD3<Float> = SIMD3<Float>(0.9, 0.95, 1.0)
    
    /// Ice roughness (0.0 = mirror, 1.0 = completely rough)
    var iceRoughness: Float = 0.15
    
    /// Ice metallic properties
    var iceMetallic: Float = 0.05
    
    /// Ice subsurface scattering intensity
    var iceSubsurface: Float = 0.3
    
    // MARK: - Noise and Variation
    
    /// Enable noise-based ice variation
    var useNoiseVariation: Bool = true
    
    /// Noise scale for ice variation
    var noiseScale: Float = 8.0
    
    /// Noise strength for ice coverage variation
    var noiseStrength: Float = 0.2
    
    /// Noise octaves for ice detail
    var noiseOctaves: Int = 3
    
    // MARK: - Seasonal/Climate Control
    
    /// Global temperature offset (-1.0 = ice age, 1.0 = greenhouse)
    var globalTemperature: Float = 0.0
    
    /// Seasonal variation strength (0.0 = no seasons, 1.0 = extreme seasons)
    var seasonalVariation: Float = 0.1
    
    /// Current season angle in radians (0 = summer, π = winter)
    var seasonAngle: Float = 0.0
    
    // MARK: - Advanced Features
    
    /// Enable dynamic ice flow patterns
    var enableIceFlow: Bool = false
    
    /// Ice flow direction noise scale
    var iceFlowScale: Float = 2.0
    
    /// Ice cracks and crevasses intensity
    var cracksIntensity: Float = 0.1
    
    // MARK: - Custom Coding for SIMD3<Float>
    
    enum CodingKeys: String, CodingKey {
        case northCapThreshold
        case southCapThreshold
        case falloffSharpness
        case useElevationMask
        case minElevationForIce
        case maxElevationForIce
        case iceThickness
        case iceColor
        case iceRoughness
        case iceMetallic
        case iceSubsurface
        case useNoiseVariation
        case noiseScale
        case noiseStrength
        case noiseOctaves
        case globalTemperature
        case seasonalVariation
        case seasonAngle
        case enableIceFlow
        case iceFlowScale
        case cracksIntensity
    }
    
    init(
        northCapThreshold: Float = 0.7,
        southCapThreshold: Float = -0.7,
        falloffSharpness: Float = 2.0,
        useElevationMask: Bool = true,
        minElevationForIce: Float = 0.3,
        maxElevationForIce: Float = 0.8,
        iceThickness: Float = 0.02,
        iceColor: SIMD3<Float> = SIMD3<Float>(0.9, 0.95, 1.0),
        iceRoughness: Float = 0.15,
        iceMetallic: Float = 0.05,
        iceSubsurface: Float = 0.3,
        useNoiseVariation: Bool = true,
        noiseScale: Float = 8.0,
        noiseStrength: Float = 0.2,
        noiseOctaves: Int = 3,
        globalTemperature: Float = 0.0,
        seasonalVariation: Float = 0.1,
        seasonAngle: Float = 0.0,
        enableIceFlow: Bool = false,
        iceFlowScale: Float = 2.0,
        cracksIntensity: Float = 0.1
    ) {
        self.northCapThreshold = northCapThreshold
        self.southCapThreshold = southCapThreshold
        self.falloffSharpness = falloffSharpness
        self.useElevationMask = useElevationMask
        self.minElevationForIce = minElevationForIce
        self.maxElevationForIce = maxElevationForIce
        self.iceThickness = iceThickness
        self.iceColor = iceColor
        self.iceRoughness = iceRoughness
        self.iceMetallic = iceMetallic
        self.iceSubsurface = iceSubsurface
        self.useNoiseVariation = useNoiseVariation
        self.noiseScale = noiseScale
        self.noiseStrength = noiseStrength
        self.noiseOctaves = noiseOctaves
        self.globalTemperature = globalTemperature
        self.seasonalVariation = seasonalVariation
        self.seasonAngle = seasonAngle
        self.enableIceFlow = enableIceFlow
        self.iceFlowScale = iceFlowScale
        self.cracksIntensity = cracksIntensity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        northCapThreshold = try container.decodeIfPresent(Float.self, forKey: .northCapThreshold) ?? 0.7
        southCapThreshold = try container.decodeIfPresent(Float.self, forKey: .southCapThreshold) ?? -0.7
        falloffSharpness = try container.decodeIfPresent(Float.self, forKey: .falloffSharpness) ?? 2.0
        useElevationMask = try container.decodeIfPresent(Bool.self, forKey: .useElevationMask) ?? true
        minElevationForIce = try container.decodeIfPresent(Float.self, forKey: .minElevationForIce) ?? 0.3
        maxElevationForIce = try container.decodeIfPresent(Float.self, forKey: .maxElevationForIce) ?? 0.8
        iceThickness = try container.decodeIfPresent(Float.self, forKey: .iceThickness) ?? 0.02
        iceRoughness = try container.decodeIfPresent(Float.self, forKey: .iceRoughness) ?? 0.15
        iceMetallic = try container.decodeIfPresent(Float.self, forKey: .iceMetallic) ?? 0.05
        iceSubsurface = try container.decodeIfPresent(Float.self, forKey: .iceSubsurface) ?? 0.3
        useNoiseVariation = try container.decodeIfPresent(Bool.self, forKey: .useNoiseVariation) ?? true
        noiseScale = try container.decodeIfPresent(Float.self, forKey: .noiseScale) ?? 8.0
        noiseStrength = try container.decodeIfPresent(Float.self, forKey: .noiseStrength) ?? 0.2
        noiseOctaves = try container.decodeIfPresent(Int.self, forKey: .noiseOctaves) ?? 3
        globalTemperature = try container.decodeIfPresent(Float.self, forKey: .globalTemperature) ?? 0.0
        seasonalVariation = try container.decodeIfPresent(Float.self, forKey: .seasonalVariation) ?? 0.1
        seasonAngle = try container.decodeIfPresent(Float.self, forKey: .seasonAngle) ?? 0.0
        enableIceFlow = try container.decodeIfPresent(Bool.self, forKey: .enableIceFlow) ?? false
        iceFlowScale = try container.decodeIfPresent(Float.self, forKey: .iceFlowScale) ?? 2.0
        cracksIntensity = try container.decodeIfPresent(Float.self, forKey: .cracksIntensity) ?? 0.1
        
        // Decode SIMD3<Float> as array
        if let iceColorArray = try container.decodeIfPresent([Float].self, forKey: .iceColor),
           iceColorArray.count == 3 {
            iceColor = SIMD3<Float>(iceColorArray[0], iceColorArray[1], iceColorArray[2])
        } else {
            iceColor = SIMD3<Float>(0.9, 0.95, 1.0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(northCapThreshold, forKey: .northCapThreshold)
        try container.encode(southCapThreshold, forKey: .southCapThreshold)
        try container.encode(falloffSharpness, forKey: .falloffSharpness)
        try container.encode(useElevationMask, forKey: .useElevationMask)
        try container.encode(minElevationForIce, forKey: .minElevationForIce)
        try container.encode(maxElevationForIce, forKey: .maxElevationForIce)
        try container.encode(iceThickness, forKey: .iceThickness)
        try container.encode(iceRoughness, forKey: .iceRoughness)
        try container.encode(iceMetallic, forKey: .iceMetallic)
        try container.encode(iceSubsurface, forKey: .iceSubsurface)
        try container.encode(useNoiseVariation, forKey: .useNoiseVariation)
        try container.encode(noiseScale, forKey: .noiseScale)
        try container.encode(noiseStrength, forKey: .noiseStrength)
        try container.encode(noiseOctaves, forKey: .noiseOctaves)
        try container.encode(globalTemperature, forKey: .globalTemperature)
        try container.encode(seasonalVariation, forKey: .seasonalVariation)
        try container.encode(seasonAngle, forKey: .seasonAngle)
        try container.encode(enableIceFlow, forKey: .enableIceFlow)
        try container.encode(iceFlowScale, forKey: .iceFlowScale)
        try container.encode(cracksIntensity, forKey: .cracksIntensity)
        
        // Encode SIMD3<Float> as array
        try container.encode([iceColor.x, iceColor.y, iceColor.z], forKey: .iceColor)
    }
    
    // MARK: - Default Configurations
    
    static let earthLike = IceCapSettings(
        northCapThreshold: 0.75,
        southCapThreshold: -0.75,
        falloffSharpness: 3.0,
        useElevationMask: true,
        minElevationForIce: 0.4,
        iceColor: SIMD3<Float>(0.92, 0.96, 1.0),
        globalTemperature: 0.0
    )
    
    static let icyWorld = IceCapSettings(
        northCapThreshold: 0.3,
        southCapThreshold: -0.3,
        falloffSharpness: 1.5,
        useElevationMask: false,
        iceThickness: 0.05,
        iceColor: SIMD3<Float>(0.85, 0.9, 0.95),
        globalTemperature: -0.8
    )
    
    static let desert = IceCapSettings(
        northCapThreshold: 0.95,
        southCapThreshold: -0.95,
        falloffSharpness: 5.0,
        useElevationMask: true,
        minElevationForIce: 0.8,
        iceThickness: 0.005,
        globalTemperature: 0.7
    )
    
}

/// Ice cap calculation utilities
extension IceCapSettings {
    
    /// Calculate ice coverage at a given world position
    func calculateIceCoverage(worldPosition: SIMD3<Float>, elevation: Float) -> Float {
        let normalizedPos = normalize(worldPosition)
        let latitude = normalizedPos.y // Y is up in RealityKit
        
        // Base polar coverage
        var iceCoverage: Float = 0.0
        
        // Northern ice cap
        if latitude > northCapThreshold {
            let northFactor = (latitude - northCapThreshold) / (1.0 - northCapThreshold)
            iceCoverage = max(iceCoverage, pow(northFactor, 1.0 / falloffSharpness))
        }
        
        // Southern ice cap
        if latitude < southCapThreshold {
            let southFactor = (southCapThreshold - latitude) / (1.0 + southCapThreshold)
            iceCoverage = max(iceCoverage, pow(southFactor, 1.0 / falloffSharpness))
        }
        
        // Apply elevation mask
        if useElevationMask && iceCoverage > 0.0 {
            let elevationFactor = smoothstep(minElevationForIce, maxElevationForIce, elevation)
            iceCoverage *= elevationFactor
        }
        
        // Apply global temperature
        let temperatureFactor = 1.0 - globalTemperature * 0.5
        iceCoverage *= max(0.0, temperatureFactor)
        
        return clamp(iceCoverage, 0.0, 1.0)
    }
    
    /// Generate noise-based ice variation
    func generateIceNoise(worldPosition: SIMD3<Float>) -> Float {
        guard useNoiseVariation else { return 1.0 }
        
        let scaledPos = worldPosition * noiseScale
        
        // Simple multi-octave noise approximation
        var noise: Float = 0.0
        var amplitude: Float = 1.0
        var frequency: Float = 1.0
        
        for _ in 0..<noiseOctaves {
            // Simple hash-based noise (replace with proper Simplex noise if available)
            noise += amplitude * hashNoise(scaledPos * frequency)
            amplitude *= 0.5
            frequency *= 2.0
        }
        
        return 1.0 + noise * noiseStrength
    }
    
    private func hashNoise(_ pos: SIMD3<Float>) -> Float {
        let p = SIMD3<Int32>(Int32(pos.x * 12.9898), Int32(pos.y * 78.233), Int32(pos.z * 37.719))
        let hash = (p.x * 73856093) ^ (p.y * 19349663) ^ (p.z * 83492791)
        return Float(hash % 65536) / 32768.0 - 1.0
    }
    
    private func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
        let t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
        return t * t * (3.0 - 2.0 * t)
    }
    
    private func clamp(_ value: Float, _ min: Float, _ max: Float) -> Float {
        return Swift.max(min, Swift.min(max, value))
    }
    
}

// MARK: - SwiftUI Integration

extension IceCapSettings {
    
    /// Convert to color for UI display
    var iceUIColor: Color {
        Color(red: Double(iceColor.x), green: Double(iceColor.y), blue: Double(iceColor.z))
    }
    
    /// Update ice color from UI color
    mutating func setIceColor(_ color: Color) {
        #if canImport(AppKit)
        let uiColor = NSColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        iceColor = SIMD3<Float>(Float(red), Float(green), Float(blue))
        #elseif canImport(UIKit)
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        iceColor = SIMD3<Float>(Float(red), Float(green), Float(blue))
        #else
        // Fallback for other platforms - extract RGB manually
        let cgColor = color.cgColor
        if let components = cgColor?.components, components.count >= 3 {
            iceColor = SIMD3<Float>(Float(components[0]), Float(components[1]), Float(components[2]))
        }
        #endif
    }
    
}
