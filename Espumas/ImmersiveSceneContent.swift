//
//  ImmersiveSceneContent.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveSceneContent: View {
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    
    @State var handTrackedEntity: Entity = {
        let handAnchor = AnchorEntity(.hand(.left, location: .aboveHand))
       // let handAnchor = AnchorEntity(.hand(.either, location: .aboveHand))
        return handAnchor
    }()
    
    
    @State var clones: [Entity] = []
    @State var originalPositions: [SIMD3<Float>] = []
    
    var body: some View {
        RealityView { content, attachments in
            if let root = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(root)
                
                if let glassSphere = root.findEntity(named: "GlassSphere") {
                    glassSphere.components[HoverEffectComponent.self] = .init()
                    createClones(root, glassSphere: glassSphere)
                }
                
                content.add(handTrackedEntity)
                if let attachmentEntity = attachments.entity(for: "AttachmentContent") {
                    attachmentEntity.components[BillboardComponent.self] = .init()
                    handTrackedEntity.addChild(attachmentEntity)
                }
                startAnimatingBubbles()
            }
        } update: { content, attachments in
            updateListenerPosition()
            
        } attachments: {
            Attachment(id: "AttachmentContent") {
                HStack(spacing: 12) {
                    Button(action: {
                        openWindow(id: "MainWindow")
                    }, label: {
                        Image(systemName: "arrow.2.circlepath.circle")
                    })
                    
                }
                .opacity(appModel.mainWindowOpen ? 0 : 1)
            }
        }
        .gesture(tap)
        .onAppear {
            configureAudioSession()
        }
    }
    
    var tap: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                let position = value.entity.position
                let audioPosition = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

                value.entity.removeFromParent()
                
                AudioManager.shared.playSound(named: "bubble", at: audioPosition)
                
            }
    }
    
    
    func createClones(_ root: Entity, glassSphere: Entity) {
        let centerPos = SIMD3<Float>(0, 1.5, 0)
        for _ in 1...50 {
            let clone = glassSphere.clone(recursive: true)
            let distance = Float.random(in: 1...3)
            let theta = Float.random(in: 0...(2 * .pi))
            let phi = Float.random(in: 0...(Float.pi))
            
            
            let x = distance * sin(phi) * cos(theta)
            let y = distance * sin(phi) * sin(theta)
            let z = distance * cos(phi)
            clone.position = centerPos + SIMD3(x, y, z)
            
            clones.append(clone)
            originalPositions.append(clone.position)
            root.addChild(clone)
        }
    }
    
    func startAnimatingBubbles() {
        
        guard !clones.isEmpty && clones.count == originalPositions.count else {
            print("Clones ou posições originais não estão configurados corretamente.")
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            for (index, clone) in clones.enumerated() {
                
                let originalPos = originalPositions[index]
                
                let randomOffset = SIMD3<Float>(
                    Float.random(in: -0.5...0.5),
                    Float.random(in: -0.5...0.5),
                    Float.random(in: -0.5...0.5)
                )
                
                clone.position = originalPos + randomOffset
            }
        }
    }
    
    func updateListenerPosition() {
        if let handEntity = handTrackedEntity as? AnchorEntity {
            let position = handEntity.position
            AudioManager.shared.updateListenerPosition(x: position.x, y: position.y, z: position.z)
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
