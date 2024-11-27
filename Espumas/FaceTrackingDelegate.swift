//
//  FaceTrackingDelegate.swift
//  Espumas
//
//  Created by marcelodearaujo on 27/11/24.
//

//import SwiftUI
//import RealityKit
//import ARKit
//
//
//class FaceTrackingDelegate: NSObject, ARSessionDelegate {
//    static let shared = FaceTrackingDelegate()
//    
//    private var lastBlinkTime: TimeInterval = 0
//    private let blinkCooldown: TimeInterval = 0.2
//    
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        for anchor in anchors {
//            guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
//            
//            let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
//            let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
//            
//            let blinkThreshold: Float = 0.5
//            
//            if (leftEyeBlink > blinkThreshold || rightEyeBlink > blinkThreshold),
//               Date().timeIntervalSince1970 - lastBlinkTime > blinkCooldown {
//                lastBlinkTime = Date().timeIntervalSince1970
//                
//                DispatchQueue.main.async {
//                    print("Piscada detectada!")
//                    // Aqui, pode chamar um método global ou notificar o SwiftUI para remover a bolha
//                }
//            }
//        }
//    }
//}
