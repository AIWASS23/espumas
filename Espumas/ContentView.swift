//
//  ContentView.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(AppModel.self) private var appModel

#if os(visionOS)
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
#endif

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {

            Text("🫧")
                .font(.extraLargeTitle2)
            Text("Agile")
                .font(.title)
            Text("Immersive Spaces")
                .font(.extraLargeTitle)

            Text("A space is open: \(appModel.immersiveSpaceActive ? "Yes" : "No")")
                .font(.system(size: 24))

            ImmersiveSpaceButton(
                isOpen: appModel.gardenMixedOpen,
                spaceID: "GardenSceneMixed",
                label: "Mixed"
            )
            ImmersiveSpaceButton(
                isOpen: appModel.gardenProgressiveOpen,
                spaceID: "GardenSceneProgressive",
                label: "Progressive"
            )
            ImmersiveSpaceButton(
                isOpen: appModel.gardenFullOpen,
                spaceID: "GardenSceneFull",
                label: "Full"
            )
        }
        .padding()
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .inactive, .background:
                appModel.mainWindowOpen = false
            case .active:
                appModel.mainWindowOpen = true
            @unknown default:
                appModel.mainWindowOpen = false
            }
        }
    }
}
