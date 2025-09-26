////
////  NoiseFilter.swift
////  ProceduralPlanets
////
////  Created by AI Assistant
////
//
//import Foundation
//import simd
//
//struct NoiseFilter {
//    let noiseSettings: NoiseSettings
//    
//    func evaluatePoint(_ pointOnUnitSphere: SIMD3<Float>) -> Float {
//        var noiseValue: Float = 0
//        var frequency = noiseSettings.baseRoughness
//        var amplitude: Float = 1
//        
//        for _ in 0..<noiseSettings.numberOfLayers {
//            let v = noise(pointOnUnitSphere * frequency + noiseSettings.center)
//            noiseValue += (v + 1) * 0.5 * amplitude
//            frequency *= noiseSettings.roughness
//            amplitude *= noiseSettings.persistance
//        }
//        
//        noiseValue = max(0, noiseValue - noiseSettings.minValue)
//        return noiseValue * noiseSettings.strength
//    }
//    
//    private func noise(_ point: SIMD3<Float>) -> Float {
//        // Simple 3D Perlin-like noise implementation
//        let x = point.x
//        let y = point.y
//        let z = point.z
//        
//        // Floor coordinates
//        let xi = Int(floor(x)) & 255
//        let yi = Int(floor(y)) & 255
//        let zi = Int(floor(z)) & 255
//        
//        // Fractional coordinates
//        let xf = x - floor(x)
//        let yf = y - floor(y)
//        let zf = z - floor(z)
//        
//        // Fade curves
//        let u = fade(xf)
//        let v = fade(yf)
//        let w = fade(zf)
//        
//        // Hash coordinates of 8 corners
//        let aaa = hash(xi, yi, zi)
//        let aba = hash(xi, yi + 1, zi)
//        let aab = hash(xi, yi, zi + 1)
//        let abb = hash(xi, yi + 1, zi + 1)
//        let baa = hash(xi + 1, yi, zi)
//        let bba = hash(xi + 1, yi + 1, zi)
//        let bab = hash(xi + 1, yi, zi + 1)
//        let bbb = hash(xi + 1, yi + 1, zi + 1)
//        
//        // Interpolate
//        let x1 = lerp(grad(aaa, xf, yf, zf), grad(baa, xf - 1, yf, zf), u)
//        let x2 = lerp(grad(aba, xf, yf - 1, zf), grad(bba, xf - 1, yf - 1, zf), u)
//        let y1 = lerp(x1, x2, v)
//        
//        let x3 = lerp(grad(aab, xf, yf, zf - 1), grad(bab, xf - 1, yf, zf - 1), u)
//        let x4 = lerp(grad(abb, xf, yf - 1, zf - 1), grad(bbb, xf - 1, yf - 1, zf - 1), u)
//        let y2 = lerp(x3, x4, v)
//        
//        return lerp(y1, y2, w)
//    }
//    
//    private func fade(_ t: Float) -> Float {
//        return t * t * t * (t * (t * 6 - 15) + 10)
//    }
//    
//    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
//        return a + t * (b - a)
//    }
//    
//    private func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
//        let h = hash & 15
//        let u = h < 8 ? x : y
//        let v = h < 4 ? y : h == 12 || h == 14 ? x : z
//        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
//    }
//    
//    private func hash(_ x: Int, _ y: Int, _ z: Int) -> Int {
//        var hash = x
//        hash = (hash &* 73856093) ^ y
//        hash = (hash &* 19349663) ^ z
//        hash = (hash &* 83492791)
//        return hash & 0x7FFFFFFF
//    }
//}
//
//class MinMax {
//    private(set) var min: Float = Float.greatestFiniteMagnitude
//    private(set) var max: Float = -Float.greatestFiniteMagnitude
//    
//    func addValue(_ value: Float) {
//        if value > max {
//            max = value
//        }
//        if value < min {
//            min = value
//        }
//    }
//}
