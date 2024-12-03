//
//  AudioManager.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/27/24.
//


import AVFoundation
import RealityKit

class AudioManager {
    static let shared = AudioManager()
    
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()
    private var audioPlayerNodes: [AVAudioPlayerNode] = []
    
    init() {
        setupAudioEngine()
    }
    
    func setupAudioEngine() {
        audioEngine.attach(environmentNode)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: nil)
        
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0.0, y: 0.0, z: 0.0)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func playSound(named fileName: String, at position: AVAudio3DPoint) {
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: environmentNode, format: nil)
        
        if let audioFileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            if let audioFile = try? AVAudioFile(forReading: audioFileURL) {
                audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            }
        }
        
        audioPlayerNode.position = position
        audioPlayerNode.reverbBlend = 0.5
        audioPlayerNodes.append(audioPlayerNode)
        audioPlayerNode.play()
    }
    
    
    func updateListenerPosition(x: Float, y: Float, z: Float) {
        environmentNode.listenerPosition = AVAudio3DPoint(x: x, y: y, z: z)
    }
    
    func playAmbientSound(named fileName: String) {
        let ambientPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(ambientPlayerNode)
        audioEngine.connect(ambientPlayerNode, to: environmentNode, format: nil)
        
        if let ambientFileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            if let ambientFile = try? AVAudioFile(forReading: ambientFileURL) {
                ambientPlayerNode.scheduleFile(ambientFile, at: nil, completionHandler: nil)
            }
        }
        
        ambientPlayerNode.position = AVAudio3DPoint(x: 0.0, y: 0.0, z: -10.0)
        ambientPlayerNode.play()
    }
    
    func playDirectionalCue(named fileName: String, from position: AVAudio3DPoint) {
        let cuePlayerNode = AVAudioPlayerNode()
        audioEngine.attach(cuePlayerNode)
        audioEngine.connect(cuePlayerNode, to: environmentNode, format: nil)
        
        if let cueFileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            if let cueFile = try? AVAudioFile(forReading: cueFileURL) {
                cuePlayerNode.scheduleFile(cueFile, at: nil, completionHandler: nil)
            }
        }
        
        cuePlayerNode.position = position
        cuePlayerNode.play()
    }
    
    func setOcclusionAndObstruction(occlusion: Float, obstruction: Float) {
        environmentNode.occlusion = occlusion
        environmentNode.obstruction = obstruction
    }
    
    func createSpatialAudio() -> Entity {
        let audioSource = Entity()
        audioSource.spatialAudio = SpatialAudioComponent(gain: -5)
        audioSource.spatialAudio?.directivity = .beam(focus: 1)
        
        do {
            let resource = try AudioFileResource.load(named: "bubble", configuration: .init(shouldLoop: true))
            audioSource.playAudio(resource)
        } catch {
            print("Error loading audio file: \\(error.localizedDescription)")
        }
        
        return audioSource
    }
}
