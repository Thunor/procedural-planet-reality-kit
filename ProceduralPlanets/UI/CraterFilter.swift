//
//  CraterFilter.swift
//  ProceduralPlanets
//
//  Created by AI Assistant
//

import Foundation
import simd

struct CraterFilter {
    let craterSettings: CraterSettings
    private let craters: [CraterData]
    
    init(craterSettings: CraterSettings) {
        self.craterSettings = craterSettings
        self.craters = Self.generateCraters(settings: craterSettings)
    }
    
    func evaluatePoint(_ pointOnUnitSphere: SIMD3<Float>) -> Float {
        var elevation: Float = 0
        
        for crater in craters {
            let craterElevation = calculateCraterElevation(
                point: pointOnUnitSphere,
                crater: crater
            )
            elevation += craterElevation
        }
        
        return elevation * craterSettings.depth
    }
    
    private func calculateCraterElevation(point: SIMD3<Float>, crater: CraterData) -> Float {
        // Calculate distance from crater center
        let distanceFromCenter = distance(point, crater.center)
        
        // If point is too far from crater, no effect
        if distanceFromCenter > crater.radius * craterSettings.fadeDistance {
            return 0
        }
        
        // Normalize distance to crater radius
        let normalizedDistance = distanceFromCenter / crater.radius
        
        if normalizedDistance <= 1.0 {
            // Inside crater
            return calculateCraterProfile(normalizedDistance: normalizedDistance, crater: crater)
        } else {
            // Outside crater but within fade distance
            let fadeDistance = craterSettings.fadeDistance
            let fadeFactor = (fadeDistance - normalizedDistance) / (fadeDistance - 1.0)
            return calculateRimProfile(normalizedDistance: normalizedDistance, crater: crater) * max(0, fadeFactor)
        }
    }
    
    private func calculateCraterProfile(normalizedDistance: Float, crater: CraterData) -> Float {
        let rimWidth = craterSettings.rimWidth
        let rimHeight = craterSettings.rimHeight * crater.depthScale
        
        if normalizedDistance <= rimWidth {
            // Rim area - create raised edge
            let rimFactor = normalizedDistance / rimWidth
            let rimProfile = sin(rimFactor * .pi) // Smooth bell curve for rim
            return rimProfile * rimHeight
        } else {
            // Interior crater - depressed area
            let interiorFactor = (normalizedDistance - rimWidth) / (1.0 - rimWidth)
            let depthProfile = smoothstep(0, 1, interiorFactor)
            return -depthProfile * crater.depthScale
        }
    }
    
    private func calculateRimProfile(normalizedDistance: Float, crater: CraterData) -> Float {
        // Slight elevation outside the crater rim for ejecta
        let ejectaFactor = 1.0 - smoothstep(1.0, craterSettings.fadeDistance, normalizedDistance)
        return ejectaFactor * craterSettings.rimHeight * crater.depthScale * 0.3
    }
    
    private static func generateCraters(settings: CraterSettings) -> [CraterData] {
        var rng = SeededRandom(seed: settings.randomSeed)
        var craters: [CraterData] = []
        
        for _ in 0..<settings.craterCount {
            let center = generateCraterCenter(distribution: settings.distribution, rng: &rng)
            let radius = Float.random(
                in: settings.minRadius...settings.maxRadius,
                using: &rng.generator
            )
            let depthScale = Float.random(in: 0.7...1.3, using: &rng.generator)
            
            let crater = CraterData(
                center: center,
                radius: radius,
                depthScale: depthScale
            )
            
            craters.append(crater)
        }
        
        return craters
    }
    
    private static func generateCraterCenter(distribution: CraterDistribution, rng: inout SeededRandom) -> SIMD3<Float> {
        switch distribution {
        case .uniform:
            return generateUniformPointOnSphere(rng: &rng)
        case .clustered:
            return generateClusteredPoint(rng: &rng)
        case .polar:
            return generatePolarPoint(rng: &rng)
        }
    }
    
    private static func generateUniformPointOnSphere(rng: inout SeededRandom) -> SIMD3<Float> {
        // Generate uniform random point on unit sphere using Muller's method
        let u = Float.random(in: 0...1, using: &rng.generator)
        let v = Float.random(in: 0...1, using: &rng.generator)
        
        let theta = 2 * Float.pi * u // Azimuthal angle
        let phi = acos(2 * v - 1) // Polar angle
        
        let x = sin(phi) * cos(theta)
        let y = sin(phi) * sin(theta)
        let z = cos(phi)
        
        return SIMD3<Float>(x, y, z)
    }
    
    private static func generateClusteredPoint(rng: inout SeededRandom) -> SIMD3<Float> {
        // Generate clusters around random centers
        let clusterCenter = generateUniformPointOnSphere(rng: &rng)
        let clusterRadius = Float.random(in: 0.1...0.3, using: &rng.generator)
        
        // Generate point near cluster center
        var point = generateUniformPointOnSphere(rng: &rng)
        point = normalize(mix(clusterCenter, point, t: clusterRadius))
        
        return point
    }
    
    private static func generatePolarPoint(rng: inout SeededRandom) -> SIMD3<Float> {
        // Bias towards polar regions
        let u = Float.random(in: 0...1, using: &rng.generator)
        let v = Float.random(in: 0...1, using: &rng.generator)
        
        let theta = 2 * Float.pi * u
        // Bias phi towards poles
        let biasedV = pow(v, 0.3) // This biases towards 0 and 1
        let phi = acos(2 * biasedV - 1)
        
        let x = sin(phi) * cos(theta)
        let y = sin(phi) * sin(theta)
        let z = cos(phi)
        
        return SIMD3<Float>(x, y, z)
    }
}

struct CraterData {
    let center: SIMD3<Float>
    let radius: Float
    let depthScale: Float
}

// Utility functions
private func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
    let t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
}

private func clamp(_ value: Float, _ minValue: Float, _ maxValue: Float) -> Float {
    return max(minValue, min(maxValue, value))
}

private func mix(_ a: SIMD3<Float>, _ b: SIMD3<Float>, t: Float) -> SIMD3<Float> {
    return a + t * (b - a)
}

// Seeded random number generator for consistent crater placement
struct SeededRandom {
    var generator: LinearCongruentialGenerator
    
    init(seed: UInt32) {
        self.generator = LinearCongruentialGenerator(seed: UInt64(seed))
    }
}

struct LinearCongruentialGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}