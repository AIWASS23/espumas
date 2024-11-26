//
//  ImmersiveSpaceButton.swift
//  Espumas
//
//  Created by marcelodearaujo on 26/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent


struct ImmersiveSpaceButton: View {
    let isOpen: Bool
    let spaceID: String
    let label: String

    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button(action: {
            Task {
                if appModel.immersiveSpaceActive {
                    await dismissImmersiveSpace()
                }
                if !isOpen {
                    await openImmersiveSpace(id: spaceID)
                }
            }
        }, label: {
            Text(isOpen ? "Close \(label) Space" : "Open \(label) Space")
        })
    }
}
