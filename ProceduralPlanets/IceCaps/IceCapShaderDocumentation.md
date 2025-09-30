# Ice Cap Shader System Documentation

## Overview

The Ice Cap Shader System is a comprehensive solution for adding realistic, configurable ice caps to procedural planets in your RealityKit-based applications. It integrates seamlessly with the existing ProceduralPlanets system and provides extensive customization options for different planetary climates.

## Key Features

- **Latitude-based Ice Formation**: Configurable northern and southern ice cap thresholds
- **Elevation Dependency**: Ice formation based on altitude and terrain elevation
- **Climate Control**: Global temperature settings affecting ice coverage
- **Noise Variation**: Procedural noise for realistic ice edge variation
- **Material Properties**: Configurable ice appearance (color, roughness, metallic properties)
- **Seasonal Variation**: Dynamic seasonal effects on ice coverage
- **Advanced Features**: Ice flow patterns and crack simulation

## Components

### 1. IceCapSettings.swift

Core configuration structure containing all ice cap parameters:

```swift
struct IceCapSettings: Equatable, Codable {
    // Basic coverage settings
    var northCapThreshold: Float = 0.7
    var southCapThreshold: Float = -0.7
    var falloffSharpness: Float = 2.0
    
    // Elevation dependencies
    var useElevationMask: Bool = true
    var minElevationForIce: Float = 0.3
    var maxElevationForIce: Float = 0.8
    
    // Ice properties
    var iceColor: SIMD3<Float> = SIMD3<Float>(0.9, 0.95, 1.0)
    var iceRoughness: Float = 0.15
    var iceMetallic: Float = 0.05
    
    // Climate control
    var globalTemperature: Float = 0.0
    
    // Noise variation
    var noiseScale: Float = 8.0
    var noiseStrength: Float = 0.2
}
```

**Predefined Presets:**
- `.earthLike`: Earth-like ice caps with moderate coverage
- `.icyWorld`: Extensive ice coverage for frozen planets
- `.desert`: Minimal ice caps for hot, arid worlds

### 2. IceCapMaterial.swift

Swift interface for managing the USD shader material:

```swift
@MainActor
class IceCapMaterial: ObservableObject {
    @Published var settings: IceCapSettings
    
    // Load material from USD file
    func loadMaterial() async throws
    
    // Update material parameters
    func updateMaterial()
    
    // Set base planet texture
    func setBaseTexture(_ texture: CGImage) throws
    
    // Get material for RealityKit
    func getMaterial() throws -> ShaderGraphMaterial
}
```

### 3. IceCapMaterial.usda

USD ShaderGraph material implementing the ice cap shader logic:

- **Input Parameters**: All configurable ice cap settings
- **Shader Nodes**: Complete node graph for ice calculation
- **Output**: PBR material with ice/surface blending

**Key Shader Components:**
- Latitude calculation from world position
- Ice coverage computation for north/south caps
- Elevation-based masking
- Noise generation for variation
- Material property blending

### 4. Integration with PlanetEntity

Extended PlanetEntity with ice cap support:

```swift
// Initialize with ice caps
let planet = try await PlanetEntity(
    meshConfiguration: meshConfig,
    imageTexture: nil,
    iceCapConfiguration: iceCapConfiguration
)

// Enable ice caps on existing planet
try await planet.enableIceCaps(with: .earthLike)

// Update ice cap settings
try planet.updateIceCapSettings(newSettings)

// Disable ice caps
await planet.disableIceCaps(elevationMin: min, elevationMax: max)
```

## Usage Guide

### Basic Implementation

1. **Add Ice Cap Configuration to Planet Model:**

```swift
let iceCapConfig = IceCapConfiguration(
    enabled: true,
    settings: .earthLike
)

let planet = PlanetModel(
    name: "Icy Planet",
    meshConfiguration: meshConfig,
    textureConfiguration: textureConfig,
    iceCapConfiguration: iceCapConfig
)
```

2. **Create Planet Entity with Ice Caps:**

```swift
let planetEntity = try await PlanetEntity(
    meshConfiguration: planet.meshConfiguration,
    imageTexture: nil,
    iceCapConfiguration: planet.iceCapConfiguration
)
```

3. **Add to RealityView:**

```swift
RealityView { content in
    content.add(planetEntity)
} update: { content in
    // Handle updates
}
```

### Advanced Customization

#### Custom Ice Cap Settings

```swift
var customSettings = IceCapSettings()
customSettings.northCapThreshold = 0.6  // Larger northern ice cap
customSettings.southCapThreshold = -0.8 // Smaller southern ice cap
customSettings.globalTemperature = -0.3 // Cooler planet
customSettings.iceColor = SIMD3<Float>(0.85, 0.9, 0.95) // Slightly blue ice
customSettings.noiseStrength = 0.4      // More variation

let iceCapMaterial = IceCapMaterial(settings: customSettings)
```

#### Dynamic Climate Control

```swift
// Simulate climate change
@State private var temperature: Float = 0.0

// In your view update
iceCapMaterial.settings.globalTemperature = temperature

// Animate temperature changes
withAnimation(.easeInOut(duration: 2.0)) {
    temperature = newTemperature
}
```

#### Seasonal Variation

```swift
// Simulate seasons
let seasonalAngle = Float(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 31536000)) // 1 year
iceCapMaterial.settings.seasonAngle = seasonalAngle * 2 * .pi
iceCapMaterial.settings.seasonalVariation = 0.3
```

### UI Integration

The system includes ready-to-use SwiftUI views:

```swift
// Basic settings view
IceCapSettingsView(iceCapMaterial: iceCapMaterial)

// Advanced controls
AdvancedIceCapControls(iceCapMaterial: iceCapMaterial)

// Complete demo view
IceCapDemoView()
```

## Shader Technical Details

### Ice Coverage Calculation

The shader uses a multi-step process to determine ice coverage:

1. **Latitude Extraction**: World position → Normalized Y component
2. **Polar Threshold**: Compare against north/south thresholds
3. **Falloff Application**: Smooth transition using configurable sharpness
4. **Elevation Masking**: Optional elevation-based ice formation
5. **Noise Variation**: Procedural variation for realistic edges
6. **Climate Modulation**: Global temperature effects

### Mathematical Formula

```glsl
// Simplified ice coverage calculation
float latitude = normalize(worldPosition).y;

// Northern ice cap
float northFactor = max(0, (latitude - northThreshold) / (1.0 - northThreshold));
float northIce = pow(northFactor, 1.0 / sharpness);

// Southern ice cap  
float southFactor = max(0, (southThreshold - latitude) / (1.0 + southThreshold));
float southIce = pow(southFactor, 1.0 / sharpness);

// Combine and apply modifiers
float iceCoverage = max(northIce, southIce);
iceCoverage *= elevationMask;
iceCoverage *= noiseVariation;
iceCoverage *= (1.0 - globalTemperature * 0.5);
```

### Performance Considerations

- **Shader Complexity**: Moderate - suitable for real-time rendering
- **Texture Sampling**: Minimal - only base texture and noise
- **Vertex vs Fragment**: All calculations in fragment shader
- **LOD Support**: Automatic through RealityKit's LOD system

## Best Practices

### Performance

1. **Adjust Noise Octaves**: Reduce for better performance on lower-end devices
2. **Use Appropriate Resolution**: Higher mesh resolution shows more ice detail
3. **Batch Updates**: Update multiple parameters at once rather than individually

### Visual Quality

1. **Elevation Dependency**: Enable for more realistic ice placement
2. **Noise Variation**: Use moderate strength (0.1-0.3) for best results
3. **Color Selection**: Slightly blue-tinted whites work best for ice
4. **Roughness Values**: Keep ice roughness low (0.1-0.3) for realistic appearance

### Integration

1. **Material Ordering**: Load ice cap material after base planet generation
2. **Texture Coordination**: Ensure base textures complement ice appearance
3. **Animation Timing**: Use slow transitions for climate changes

## Troubleshooting

### Common Issues

**Material Not Loading:**
- Ensure `IceCapMaterial.usda` is included in app bundle
- Check that `loadMaterial()` is called before use
- Verify USD file syntax is correct

**Ice Not Appearing:**
- Check threshold values (should be between -1 and 1)
- Verify `globalTemperature` isn't too high
- Ensure elevation mask settings allow ice formation

**Performance Issues:**
- Reduce `noiseOctaves` in settings
- Lower mesh resolution for preview modes
- Disable advanced features for mobile devices

**Visual Artifacts:**
- Check mesh resolution is sufficient for ice detail
- Verify normal vectors are correctly calculated
- Ensure proper UV mapping for base textures

### Debug Tips

1. **Parameter Visualization**: Use extreme values to verify parameter effects
2. **Fallback Materials**: Implement fallbacks for shader loading failures
3. **Performance Monitoring**: Monitor frame rates when enabling ice caps
4. **Platform Testing**: Test on target devices early in development

## Example Projects

### Earth-like Planet

```swift
let earthSettings = IceCapSettings.earthLike
earthSettings.seasonalVariation = 0.15
let earth = createPlanet(with: earthSettings)
```

### Frozen Moon

```swift
let frozenSettings = IceCapSettings.icyWorld
frozenSettings.northCapThreshold = 0.3
frozenSettings.globalTemperature = -0.8
let moon = createPlanet(with: frozenSettings)
```

### Desert World

```swift
let desertSettings = IceCapSettings.desert
desertSettings.minElevationForIce = 0.9
desertSettings.iceThickness = 0.002
let desert = createPlanet(with: desertSettings)
```

## Future Enhancements

Potential improvements for the ice cap shader system:

1. **Multi-layer Ice**: Different ice types (snow, glacial ice, permafrost)
2. **Ice Physics**: Melting/freezing animations based on temperature changes
3. **Atmospheric Integration**: Cloud coverage affecting ice formation
4. **Tidal Effects**: Ice formation based on proximity to other bodies
5. **Historical Climate**: Ice layer buildup over geological time
6. **Advanced Rendering**: Subsurface scattering, ice crystal reflections

## API Reference

For complete API documentation, see the inline comments in each Swift file. Key classes and methods are documented with full parameter descriptions and usage examples.
