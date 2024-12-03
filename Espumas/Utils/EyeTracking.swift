//
//  EyeTracking.swift
//  Espumas
//
//  Created by marcelodearaujo on 27/11/24.
//

import SwiftUI
import RealityKit
import ARKit
import UIKit

#if os(macOS)

class EyeTracking: ARView, ARSessionDelegate {
    
    @Binding var LeftisWinking: Bool
    @Binding var RightisWinking: Bool
    
    init(LeftisWinking: Binding<Bool>, RightisWinking: Binding<Bool>) {
       
        _LeftisWinking = LeftisWinking
        _RightisWinking = RightisWinking
    
        super.init(frame: .zero)
        
        self.session.delegate = self
        
        let configuration = ARFaceTrackingConfiguration()
        self.session.run(configuration)
    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        detectBlink(faceAnchor: faceAnchor)
    }
    
    
    func detectBlink(faceAnchor: ARFaceAnchor) {
        
        let blendShapes = faceAnchor.blendShapes
        
        if let leftEyeBlink = blendShapes[.eyeBlinkLeft] as? Float,
           let rightEyeBlink = blendShapes[.eyeBlinkRight] as? Float {
            
            if rightEyeBlink > 0.8 {
                RightisWinking = true
            } else {
                RightisWinking = false
            }
            
            if leftEyeBlink > 0.8 {
                LeftisWinking = true
            } else {
                LeftisWinking = false
            }
            
        }
    }
    
    func detectGazePoint(faceAnchor: ARFaceAnchor){
        let lookAtPoint = faceAnchor.lookAtPoint
        
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }
        
        let lookAtPointInWorld = faceAnchor.transform * simd_float4(lookAtPoint, 1)
        
        let transformedLookAtPoint = simd_mul(simd_inverse(cameraTransform), lookAtPointInWorld)
        
        let screenX = transformedLookAtPoint.y / (Float(UIScreen.main.bounds.width) / 2) * Float(UIScreen.main.bounds.size.width)
        let screenY = transformedLookAtPoint.x / (Float(UIScreen.main.bounds.height) / 2) * Float(UIScreen.main.bounds.size.height)
        
        let focusPoint = CGPoint(
            x: CGFloat(screenX).clamped(to: Ranges.widthRange),
            y: CGFloat(screenY).clamped(to: Ranges.heightRange)
        )
        
        DispatchQueue.main.async {
            self.lookAtPoint = focusPoint
        }
    }
    
   @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}

struct Ranges {
    static let widthRange: ClosedRange<CGFloat> = (0...UIScreen.main.bounds.size.width)
    static let heightRange: ClosedRange<CGFloat> = (0...UIScreen.main.bounds.size.height)
}

#endif
