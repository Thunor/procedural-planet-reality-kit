//
//  NoiseFilter.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 7/23/24.
//

struct NoiseFilter {
    
    let noiseSettings: NoiseSettings
    
    func evaluatePoint(_ point: SIMD3<Float>) -> Float {
        var noise: Float = 0
        var frequency = noiseSettings.baseRoughness
        var amplitude: Float = 1
        
        for _ in 0..<noiseSettings.numberOfLayers {
            let input = point * frequency + noiseSettings.center
            let classic3d = ClassicNoise3D(amplitude: Double(amplitude), frequency: Double(frequency), seed: 0)
            let n = Float(classic3d.evaluate(Double(input.x), Double(input.y), Double(input.z)))
            noise += (n + 1) * 0.5 * amplitude
            frequency *= noiseSettings.roughness
            amplitude *= noiseSettings.persistance
        }
        noise = max(0, noise-noiseSettings.minValue)
        return noise * noiseSettings.strength
    }
    
}
