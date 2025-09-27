//
//  PlanetGallery.swift
//  ProceduralPlanets
//
//  Created by Tassilo von Gerlach on 8/6/24.
//

import Foundation
import SwiftUI
import RealityKit
import CoreGraphics

struct EditorControlsView: View {
    
    var viewModel: PlanetEditorViewModel
    
    @State private var selectedTab = 0
    let tabs = ["Mesh", "Materials"]
    
    var body: some View {
        SegmentedTabView(selectedTab: $selectedTab, tabs: tabs) { index in
            switch index {
            case 0:
                @Bindable var viewModel = viewModel
                MeshSettingsView(planetConfiguration: $viewModel.meshConfiguration)
            case 1:
                MaterialSettingsView(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .padding()
    }
    
}

@Observable
class PlanetEditorViewModel {
    
    var meshConfiguration: MeshConfiguration
    var textureConfiguration: TextureConfiguration {
        didSet {
            self.textureImage = createProceduralPlanetTexture(size: .init(width: 200, height: 100))
        }
    }
    var planetName: String
    
    var textureImage: CGImage?
    
    private var planetModel: PlanetModel
    
    init(planetModel: PlanetModel) {
        self.planetModel = planetModel
        self.meshConfiguration = planetModel.meshConfiguration
        self.textureConfiguration = planetModel.textureConfiguration
        self.planetName = planetModel.name
        self.textureImage = createProceduralPlanetTexture(size: .init(width: 200, height: 100))
    }
    
    func save() {
        planetModel.name = planetName
        planetModel.meshConfiguration = self.meshConfiguration
        planetModel.textureConfiguration = self.textureConfiguration
    }
    
    func createProceduralPlanetTexture(size: CGSize) -> CGImage? {
        guard let cgImage = createMultiColorGradient(size: size, gradientPoints: textureConfiguration.gradientPoints) else {
            return nil
        }
    
        return cgImage
    }
    
    func createMultiColorGradient(size: CGSize, gradientPoints: [GradientPoint]) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let cgColors = gradientPoints.map { $0.color.cgColor } as CFArray
        let locations = gradientPoints.map({ CGFloat($0.position) })
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: locations) else {
            return nil
        }
        
        // Use CGContext for macOS instead of UIGraphics
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: size.width, y: 0),
                                   options: [])
        
        return context.makeImage()
    }
    
}

struct PlanetEditorView: View {
    
    @State var viewModel: PlanetEditorViewModel
    
    init(planetModel: PlanetModel) {
        _viewModel = State(initialValue: PlanetEditorViewModel(planetModel: planetModel))
    }
    
    var body: some View {
        HSplitView {
            // Controls sidebar
            VStack {
                EditorControlsView(viewModel: viewModel)
                Spacer()
            }
            .frame(minWidth: 300, maxWidth: 400)
            .background(Color(Color.gray))
            
            // 3D Planet view
            VStack {
                PlanetView(viewModel: viewModel)
                    .frame(minWidth: 400, minHeight: 400)
            }
        }
        .navigationTitle(viewModel.planetName)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Save") {
                    viewModel.save()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
                                                         
}

#Preview("Planet Editor") {
    PlanetEditorView(planetModel: .samplePlanet())
        .frame(width: 1000, height: 700)
}
