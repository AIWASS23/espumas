//
//  AppModel.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/22/24.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    var mainWindowOpen: Bool = false
    var gardenMixedOpen: Bool = false
    var gardenProgressiveOpen: Bool = false
    var gardenFullOpen: Bool = false

    var progressiveGarden: ImmersionStyle = .progressive(
        0.2...0.8,
        initialAmount: 0.4
    )

    var immersiveSpaceActive: Bool {
        return gardenMixedOpen || gardenProgressiveOpen || gardenFullOpen
    }
}

