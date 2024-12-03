//
//  Extension.swift
//  Espumas
//
//  Created by marcelodearaujo on 11/28/24.
//

import Foundation
import RealityKit

extension Entity {
    
    /*
        Pesquisa recursivamente a entidade e seus filhos por uma ModelEntity que pode ter física aplicada a ela,
        retornando a primeira `ModelEntity` descoberta de descendentes de uma instância Entity.
    */
    
    func findModelEntity() -> ModelEntity? {
        if let modelEntity = self as? ModelEntity {
            return modelEntity
        }
        
        for child in self.children {
            if let found = child.findModelEntity() {
                return found
            }
        }
        
        print(self)
        
        return nil
    }
    
    /*
        Pesquisa recursivamente a entidade e seus filhos para todas as entidades com um determinado tipo de componente.
    */
    func findEntitiesWithComponent<T: Component>(_ componentType: T.Type) -> [Entity] {
        var entitiesWithComponent: [Entity] = []

        if self.components[componentType] != nil {
            entitiesWithComponent.append(self)
        }

        for child in self.children {
            entitiesWithComponent.append(contentsOf: child.findEntitiesWithComponent(componentType))
        }

        return entitiesWithComponent
    }
    
    /*
        Adiciona uma luz baseada em imagem que emula a luz do sol, este método pressupõe que seu projeto contém uma pasta que
        contém uma imagem de um ponto branco em um fundo preto. A posição do ponto na imagem determina a direção
        da qual a luz do sol se origina. Use um pequeno ponto para maximizar a natureza pontual da fonte de luz.
        Ajuste o parâmetro de intensidade para obter o brilho necessário.
    */
    func setBrightness(intensity: Float?) {
        if let intensity {
            Task {
                guard let resource = try? await EnvironmentResource(named: "YOUR_DIRECTORY") else { return }
                var iblComponent = ImageBasedLightComponent(
                    source: .single(resource),
                    intensityExponent: intensity)

                iblComponent.inheritsRotation = true

                components.set(iblComponent)
                components.set(ImageBasedLightReceiverComponent(imageBasedLight: self))
            }
        } else {
            components.remove(ImageBasedLightComponent.self)
            components.remove(ImageBasedLightReceiverComponent.self)
        }
    }
}

extension Double {
    var toDate: Date {
        return Date(timeIntervalSince1970: self)
    }
    
    var intervalToNow: TimeInterval {
        return Date.now.timeIntervalSince(self.toDate)
    }
}

extension Date {
    var toDouble: Double {
        return self.timeIntervalSince1970
    }
    
    static func nowToDouble() -> Double {
        return Self.now.timeIntervalSince1970
    }
}

extension simd_quatf {
    func convertToEulerAngles() -> SIMD3<Float> {
        let q = self
        let sinr_cosp = 2 * (q.real * q.imag.z + q.imag.x * q.imag.y)
        let cosr_cosp = 1 - 2 * (q.imag.z * q.imag.z + q.imag.x * q.imag.x)
        
        var roll = atan2(sinr_cosp, cosr_cosp)
        let sinp = 2 * (q.real * q.imag.x - q.imag.y * q.imag.z)
        
        var pitch: Float
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp)
        } else {
            pitch = asin(sinp)
        }
        
        let siny_cosp = 2 * (q.real * q.imag.y + q.imag.z * q.imag.x)
        let cosy_cosp = 1 - 2 * (q.imag.x * q.imag.x + q.imag.y * q.imag.y)

        var yaw = atan2(siny_cosp, cosy_cosp)
        
        roll = roll * 180 / .pi
        pitch = pitch * 180 / .pi
        yaw = yaw * 180 / .pi

        return SIMD3<Float>(yaw, pitch, roll)
    }
}

extension Entity {
    
    func enumerateHierarchy(_ body: (Entity, UnsafeMutablePointer<Bool>) -> Void) {
        var stop = false

        func enumerate(_ body: (Entity, UnsafeMutablePointer<Bool>) -> Void) {
            guard !stop else {
                return
            }
            body(self, &stop)
            
            for child in children {
                guard !stop else {
                    break
                }
                child.enumerateHierarchy(body)
            }
        }
        enumerate(body)
    }
}

extension SIMD3 where Scalar == Float {
    func distance(from other: SIMD3<Float>) -> Float {
        return simd_distance(self, other)
    }

    var printed: String {
        String(format: "(%.8f, %.8f, %.8f)", x, y, z)
    }

    static func spawnPoint(from: SIMD3<Float>, radius: Float) -> SIMD3<Float> {
        from + (radius == 0 ? .zero : SIMD3<Float>.random(in: Float(-radius)..<Float(radius)))
    }

    func angle(other: SIMD3<Float>) -> Float {
        atan2f(other.x - self.x, other.z - self.z) + Float.pi
    }

    var length: Float { return distance(from: .init()) }

    var isNaN: Bool {
        x.isNaN || y.isNaN || z.isNaN
    }

    var normalized: SIMD3<Float> {
        return self / length
    }

    static let up: Self = .init(0, 1, 0)

    func vector(to b: SIMD3<Float>) -> SIMD3<Float> {
        b - self
    }

    var isVertical: Bool {
        dot(self, Self.up) > 0.9
    }
}

extension SIMD2 where Scalar == Float {
    func distance(from other: Self) -> Float {
        return simd_distance(self, other)
    }

    var length: Float { return distance(from: .init()) }
}

extension BoundingBox {

    var volume: Float { extents.x * extents.y * extents.z }
}



extension Entity {
    func distance(from other: Entity) -> Float {
        transform.translation.distance(from: other.transform.translation)
    }
    
    func distance(from point: SIMD3<Float>) -> Float {
        transform.translation.distance(from: point)
    }

    func isDistanceWithinThreshold(from other: Entity, max: Float) -> Bool {
        isDistanceWithinThreshold(from: transform.translation, max: max)
    }

    func isDistanceWithinThreshold(from point: SIMD3<Float>, max: Float) -> Bool {
        transform.translation.distance(from: point) < max
    }
}

extension simd_float4x4 {

    var position: SIMD3<Float> {
        SIMD3<Float>(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }

    var rotation: simd_quatf {
        let x = simd_float3(self.columns.0.x, self.columns.0.y, self.columns.0.z)
        let y = simd_float3(self.columns.1.x, self.columns.1.y, self.columns.1.z)
        let z = simd_float3(self.columns.2.x, self.columns.2.y, self.columns.2.z)

        let scaleX = simd_length(x)
        let scaleY = simd_length(y)
        let scaleZ = simd_length(z)

        let sign = simd_sign(self.columns.0.x * self.columns.1.y * self.columns.2.z +
                             self.columns.0.y * self.columns.1.z * self.columns.2.x +
                             self.columns.0.z * self.columns.1.x * self.columns.2.y -
                             self.columns.0.z * self.columns.1.y * self.columns.2.x -
                             self.columns.0.y * self.columns.1.x * self.columns.2.z -
                             self.columns.0.x * self.columns.1.z * self.columns.2.y)

        let rotationMatrix = simd_float3x3(x/scaleX, y/scaleY, z/scaleZ)
        let quaternion = simd_quaternion(rotationMatrix)

        return sign >= 0 ? quaternion : -quaternion
    }
}

extension CGFloat {
    func clamped(to: ClosedRange<CGFloat>) -> CGFloat {
        return to.lowerBound > self ? to.lowerBound : to.upperBound < self ? to.upperBound : self
    }
}

