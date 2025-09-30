//class IceCapShaderTests: XCTestCase {
//    
//    func testIceCapSettingsCreation() throws {
//        let settings = IceCapSettings()
//        
//        XCTAssertEqual(settings.northCapThreshold, 0.7)
//        XCTAssertEqual(settings.southCapThreshold, -0.7)
//        XCTAssertEqual(settings.falloffSharpness, 2.0)
//        XCTAssertEqual(settings.useElevationMask, true)
//        XCTAssertEqual(settings.globalTemperature, 0.0)
//    }
//    
//    func testPredefinedPresets() throws {
//        let earthLike = IceCapSettings.earthLike
//        let icyWorld = IceCapSettings.icyWorld
//        let desert = IceCapSettings.desert
//        
//        // Earth-like should have moderate ice caps
//        XCTAssertEqual(earthLike.northCapThreshold, 0.75)
//        XCTAssertEqual(earthLike.globalTemperature, 0.0)
//        
//        // Icy world should have extensive ice coverage
//        XCTAssertLessThan(icyWorld.northCapThreshold, earthLike.northCapThreshold)
//        XCTAssertLessThan(icyWorld.globalTemperature, 0.0)
//        
//        // Desert should have minimal ice
//        XCTAssertGreaterThan(desert.northCapThreshold, earthLike.northCapThreshold)
//        XCTAssertGreaterThan(desert.globalTemperature, 0.0)
//    }
//    
//    func testIceCoverageCalculation() throws {
//        let settings = IceCapSettings.earthLike
//        
//        // Test northern hemisphere points
//        let northPole = SIMD3<Float>(0, 1, 0)      // Y = 1 (north pole)
//        let northTropic = SIMD3<Float>(0, 0.8, 0)  // Y = 0.8 (above threshold)
//        let equator = SIMD3<Float>(1, 0, 0)        // Y = 0 (equator)
//        let southPole = SIMD3<Float>(0, -1, 0)     // Y = -1 (south pole)
//        
//        // North pole should have maximum ice coverage
//        let northPoleIce = settings.calculateIceCoverage(worldPosition: northPole, elevation: 0.5)
//        XCTAssertGreaterThan(northPoleIce, 0.8, "North pole should have high ice coverage")
//        
//        // Equator should have no ice coverage
//        let equatorIce = settings.calculateIceCoverage(worldPosition: equator, elevation: 0.5)
//        XCTAssertLessThan(equatorIce, 0.1, "Equator should have minimal ice coverage")
//        
//        // South pole should have maximum ice coverage
//        let southPoleIce = settings.calculateIceCoverage(worldPosition: southPole, elevation: 0.5)
//        XCTAssertGreaterThan(southPoleIce, 0.8, "South pole should have high ice coverage")
//    }
//    
//    func testElevationMasking() throws {
//        var settings = IceCapSettings.earthLike
//        settings.useElevationMask = true
//        settings.minElevationForIce = 0.5
//        settings.maxElevationForIce = 1.0
//        
//        let northPole = SIMD3<Float>(0, 1, 0)
//        
//        // Low elevation should reduce ice coverage
//        let lowElevationIce = settings.calculateIceCoverage(worldPosition: northPole, elevation: 0.2)
//        
//        // High elevation should allow full ice coverage
//        let highElevationIce = settings.calculateIceCoverage(worldPosition: northPole, elevation: 0.8)
//        
//        XCTAssertLessThan(lowElevationIce, highElevationIce, "Higher elevation should have more ice")
//        
//        // Test without elevation masking
//        settings.useElevationMask = false
//        let noMaskIce = settings.calculateIceCoverage(worldPosition: northPole, elevation: 0.2)
//        XCTAssertGreaterThan(noMaskIce, lowElevationIce, "Disabling elevation mask should increase ice coverage")
//    }
//    
//    func testGlobalTemperatureEffect() throws {
//        let northPole = SIMD3<Float>(0, 1, 0)
//        let elevation: Float = 0.5
//        
//        // Cold temperature
//        var coldSettings = IceCapSettings.earthLike
//        coldSettings.globalTemperature = -0.5
//        let coldIce = coldSettings.calculateIceCoverage(worldPosition: northPole, elevation: elevation)
//        
//        // Hot temperature
//        var hotSettings = IceCapSettings.earthLike
//        hotSettings.globalTemperature = 0.5
//        let hotIce = hotSettings.calculateIceCoverage(worldPosition: northPole, elevation: elevation)
//        
//        XCTAssertGreaterThan(coldIce, hotIce, "Colder temperature should result in more ice")
//    }
//    
//    func testIceCapConfiguration() throws {
//        let settings = IceCapSettings.earthLike
//        let config = IceCapConfiguration(enabled: true, settings: settings)
//        
//        XCTAssertEqual(config.enabled, true)
//        XCTAssertEqual(config.settings.northCapThreshold, settings.northCapThreshold)
//        
//        // Test disabled configuration
//        let disabledConfig = IceCapConfiguration(enabled: false, settings: settings)
//        XCTAssertEqual(disabledConfig.enabled, false)
//    }
//    
//    func testColorConversion() throws {
//        var settings = IceCapSettings()
//        settings.iceColor = SIMD3<Float>(0.9, 0.95, 1.0)
//        
//        let uiColor = settings.iceUIColor
//        
//        // Verify color components are in reasonable range
//        // Note: Exact comparison may not work due to color space conversions
//        XCTAssertTrue(uiColor.description.contains("0.9") || uiColor.description.contains("0.95"), 
//                     "Color conversion should preserve approximate values")
//    }
//    
//    func testFalloffSharpness() throws {
//        let northPole = SIMD3<Float>(0, 1, 0)
//        let nearThreshold = SIMD3<Float>(0, 0.75, 0) // Just above threshold
//        let elevation: Float = 0.5
//        
//        // Sharp falloff
//        var sharpSettings = IceCapSettings.earthLike
//        sharpSettings.falloffSharpness = 5.0
//        let sharpIce = sharpSettings.calculateIceCoverage(worldPosition: nearThreshold, elevation: elevation)
//        
//        // Gentle falloff
//        var gentleSettings = IceCapSettings.earthLike
//        gentleSettings.falloffSharpness = 1.0
//        let gentleIce = gentleSettings.calculateIceCoverage(worldPosition: nearThreshold, elevation: elevation)
//        
//        XCTAssertLessThan(sharpIce, gentleIce, "Sharp falloff should result in less ice at threshold boundary")
//    }
//    
//    func testNoiseGeneration() throws {
//        let settings = IceCapSettings()
//        
//        let pos1 = SIMD3<Float>(1, 0, 0)
//        let pos2 = SIMD3<Float>(-1, 0, 0)
//        
//        let noise1 = settings.generateIceNoise(worldPosition: pos1)
//        let noise2 = settings.generateIceNoise(worldPosition: pos2)
//        
//        // Noise should be different for different positions
//        XCTAssertNotEqual(noise1, noise2, "Noise should vary across positions")
//        
//        // Noise should be centered around 1.0
//        XCTAssertTrue(noise1 > 0.5 && noise1 < 1.5, "Noise should be in reasonable range")
//        XCTAssertTrue(noise2 > 0.5 && noise2 < 1.5, "Noise should be in reasonable range")
//    }
//    
//    func testSettingsValidation() throws {
//        var settings = IceCapSettings()
//        
//        // Test threshold ordering
//        settings.northCapThreshold = 0.8
//        settings.southCapThreshold = -0.8
//        XCTAssertGreaterThan(settings.northCapThreshold, settings.southCapThreshold, 
//                           "North threshold should be greater than south threshold")
//        
//        // Test elevation ordering
//        settings.minElevationForIce = 0.3
//        settings.maxElevationForIce = 0.8
//        XCTAssertLessThan(settings.minElevationForIce, settings.maxElevationForIce,
//                         "Min elevation should be less than max elevation")
//        
//        // Test reasonable ranges
//        XCTAssertTrue(settings.iceRoughness >= 0.0 && settings.iceRoughness <= 1.0,
//                     "Ice roughness should be in valid range")
//        XCTAssertTrue(settings.iceMetallic >= 0.0 && settings.iceMetallic <= 1.0,
//                     "Ice metallic should be in valid range")
//    }
//    
//}
//
//class IceCapMaterialTests: XCTestCase {
//    
//    func testMaterialCreation() throws {
//        let settings = IceCapSettings.earthLike
//        let material = IceCapMaterial(settings: settings)
//        
//        XCTAssertEqual(material.settings.northCapThreshold, settings.northCapThreshold)
//        XCTAssertEqual(material.settings.iceColor, settings.iceColor)
//    }
//    
//    func testPresetMaterials() throws {
//        let earthLike = IceCapMaterial.earthLike()
//        let icyWorld = IceCapMaterial.icyWorld()
//        let desert = IceCapMaterial.desert()
//        
//        XCTAssertEqual(earthLike.settings.globalTemperature, 0.0)
//        XCTAssertLessThan(icyWorld.settings.globalTemperature, 0.0)
//        XCTAssertGreaterThan(desert.settings.globalTemperature, 0.0)
//    }
//    
//    func testSettingsUpdate() throws {
//        let material = IceCapMaterial()
//        let originalThreshold = material.settings.northCapThreshold
//        
//        material.settings.northCapThreshold = 0.9
//        
//        XCTAssertEqual(material.settings.northCapThreshold, 0.9)
//        XCTAssertNotEqual(material.settings.northCapThreshold, originalThreshold)
//    }
//    
//}
