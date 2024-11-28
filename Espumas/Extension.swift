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
