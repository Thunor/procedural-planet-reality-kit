//
//  IceCapConfiguration.swift
//  ProceduralPlanets
//
//  Created by Assistant on 9/30/25.
//

import Foundation

/// Configuration for ice cap features on a planet
struct IceCapConfiguration: Codable, Equatable, Hashable {
    /// Whether the ice caps are enabled
    var enabled: Bool
    
    /// The settings for the ice caps
    var settings: IceCapSettings
    
    init(enabled: Bool = false, settings: IceCapSettings = .earthLike) {
        self.enabled = enabled
        self.settings = settings
    }
    
    // MARK: - Preset Configurations
    
    /// Configuration for Earth-like ice caps
    static let earthLike = IceCapConfiguration(
        enabled: true,
        settings: .earthLike
    )
    
    /// Configuration for an icy world
    static let icyWorld = IceCapConfiguration(
        enabled: true,
        settings: .icyWorld
    )
    
    /// Configuration for a desert world with minimal ice
    static let desert = IceCapConfiguration(
        enabled: true,
        settings: .desert
    )
    
    /// Disabled ice caps configuration
    static let disabled = IceCapConfiguration(
        enabled: false,
        settings: .earthLike
    )
}