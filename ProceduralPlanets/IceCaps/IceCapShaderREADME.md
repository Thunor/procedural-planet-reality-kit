The ice cap settings are now fixed and should be working properly.

A sophisticated shader system for adding configurable ice caps to procedural planets in RealityKit-based applications.

## Features

- 🌍 **Realistic Ice Formation**: Latitude and elevation-based ice coverage
- 🎨 **Fully Customizable**: Extensive configuration options for different planetary types
- ⚡ **Real-time Performance**: Optimized shaders for smooth 60fps rendering
- 🧊 **Multiple Presets**: Earth-like, Icy World, and Desert planet configurations
- 🌡️ **Climate Control**: Global temperature and seasonal variation effects
- 🔧 **Easy Integration**: Drop-in compatibility with existing ProceduralPlanets system

## Quick Start

### 1. Basic Ice Cap Planet

```swift
import SwiftUI
import RealityKit

struct IcePlanetView: View {
    @State private var planetEntity: PlanetEntity?
    
    var body: some View {
        RealityView { content in
            await loadPlanet(into: content)
        }
        .realityViewCameraControls(.orbit)
    }
    
    @MainActor
    private func loadPlanet(into content: RealityViewContent) async {
        // Create ice cap configuration
        let iceCapConfig = IceCapConfiguration(
            enabled: true,
            settings: .earthLike  // Use Earth-like preset
        )
        
        // Create planet with ice caps
        let planet = try! await PlanetEntity(
            meshConfiguration: createMeshConfig(),
            imageTexture: nil,
            iceCapConfiguration: iceCapConfig
        )
        
        content.add(planet)
        self.planetEntity = planet
    }
}
```

### 2. Custom Ice Cap Settings

```swift
// Create custom ice cap configuration
var customSettings = IceCapSettings()
customSettings.northCapThreshold = 0.6      // Larger northern ice cap
customSettings.globalTemperature = -0.3     // Colder climate
customSettings.iceColor = SIMD3<Float>(0.85, 0.9, 0.95)  // Blue-tinted ice
customSettings.noiseStrength = 0.3          // More edge variation

let iceCapConfig = IceCapConfiguration(enabled: true, settings: customSettings)
```

### 3. Interactive Controls

```swift
struct PlanetControlsView: View {
    @StateObject private var iceCapMaterial = IceCapMaterial.earthLike()
    
    var body: some View {
        VStack {
            // 3D planet view
            RealityView { content in
                // Load planet with ice cap material
            }
            
            // Ice cap controls
            IceCapSettingsView(iceCapMaterial: iceCapMaterial)
        }
    }
}
```

## Presets

### Earth-like
- Moderate polar ice caps
- Elevation-dependent ice formation
- Seasonal variation support

### Icy World
- Extensive ice coverage
- Lower temperature threshold
- Thick ice caps extending toward equator

### Desert Planet
- Minimal ice caps only at extreme poles
- High elevation requirement for ice
- Very thin ice layers

## Key Components

| File | Description |
|------|-------------|
| `IceCapSettings.swift` | Configuration structure with all ice cap parameters |
| `IceCapMaterial.swift` | Swift interface for managing the USD shader material |
| `IceCapMaterial.usda` | USD ShaderGraph implementing the ice cap rendering logic |
| `IceCapDemoView.swift` | Complete demo view with interactive controls |

## Configuration Options

### Ice Coverage
- **North/South Cap Thresholds**: Control ice cap extent (0.0 to 1.0)
- **Falloff Sharpness**: Edge transition smoothness (0.5 to 10.0)
- **Elevation Masking**: Ice formation based on altitude

### Climate
- **Global Temperature**: Overall planet temperature (-1.0 to 1.0)
- **Seasonal Variation**: Dynamic seasonal ice changes (0.0 to 1.0)
- **Season Angle**: Current season phase (0 to 2π)

### Appearance
- **Ice Color**: RGB color values for ice appearance
- **Ice Roughness**: Surface roughness (0.0 = mirror, 1.0 = matte)
- **Ice Metallic**: Metallic properties (0.0 to 1.0)
- **Ice Thickness**: Visual ice layer thickness

### Variation
- **Noise Scale**: Procedural variation detail level
- **Noise Strength**: Amount of edge variation
- **Ice Flow**: Advanced flow pattern simulation

## Performance

- **Target FPS**: 60fps on modern devices
- **Shader Complexity**: Medium (fragment shader heavy)
- **Memory Usage**: Minimal additional overhead
- **Platform Support**: macOS 14+, iOS 17+, visionOS 1+

## Integration

### With Existing Planets

```swift
// Add ice caps to existing planet
try await existingPlanet.enableIceCaps(with: .earthLike)

// Update ice cap settings
try existingPlanet.updateIceCapSettings(newSettings)

// Remove ice caps
await existingPlanet.disableIceCaps(elevationMin: min, elevationMax: max)
```

### Custom Material Blending

```swift
// Create hybrid material with base terrain and ice caps
let hybridMaterial = try await planet.createHybridMaterial(
    baseElevationMin: shapeGenerator.elevationMinMax.min,
    baseElevationMax: shapeGenerator.elevationMinMax.max,
    iceCapMaterial: iceCapMaterial
)
```

## Demo App

Run the included `IceCapDemoView` to see all features in action:

```swift
NavigationStack {
    IceCapDemoView()
}
```

Features:
- Interactive parameter adjustment
- Real-time shader preview
- Preset switching
- Advanced controls panel

## Examples

### Climate Animation

```swift
// Animate global warming/cooling
withAnimation(.easeInOut(duration: 5.0)) {
    iceCapMaterial.settings.globalTemperature = targetTemperature
}
```

### Seasonal Cycle

```swift
// 24-hour seasonal cycle
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let seasonProgress = (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 86400)) / 86400
    iceCapMaterial.settings.seasonAngle = Float(seasonProgress * 2 * .pi)
}
```

### Dynamic Planet Types

```swift
enum PlanetType: CaseIterable {
    case earthLike, frozen, desert, volcanic
    
    var iceCapSettings: IceCapSettings {
        switch self {
        case .earthLike: return .earthLike
        case .frozen: return .icyWorld
        case .desert: return .desert
        case .volcanic: 
            var settings = IceCapSettings.desert
            settings.globalTemperature = 0.8
            return settings
        }
    }
}
```

## Troubleshooting

### Common Issues

**Ice caps not visible:**
- Check global temperature (should be ≤ 0.5 for visible ice)
- Verify threshold values are reasonable (-1.0 to 1.0)
- Ensure elevation mask allows ice formation

**Performance issues:**
- Reduce noise octaves in settings
- Lower mesh resolution for preview
- Disable advanced features on older devices

**Material not loading:**
- Verify `IceCapMaterial.usda` is in app bundle
- Ensure `loadMaterial()` is called before use
- Check console for USD loading errors

## Requirements

- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Platforms**: macOS 14.0+, iOS 17.0+, visionOS 1.0+
- **Frameworks**: RealityKit, SwiftUI, Foundation

## License

This ice cap shader system is part of the ProceduralPlanets project. See project license for details.

---

For complete technical documentation, see `IceCapShaderDocumentation.md`.
