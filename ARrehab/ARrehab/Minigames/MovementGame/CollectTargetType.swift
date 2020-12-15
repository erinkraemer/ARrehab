//
//  CollectTargetType.swift
//  ARrehab
//
//  Created by Erin Kraemer on 12/7/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/**
 Set of CollectTarget types. These are the objects that you can pick up during the movement game.
 */
enum CollectTargetType {
    case colorful, tealMarble, blueMarble, yellowMarble, orangeMarble
    
    /**
     A list of all the possible target types.
     */
    static var allTypes: [CollectTargetType] = [.colorful, .tealMarble, .blueMarble, .yellowMarble, .orangeMarble]
    
    /**
     The names of each type.
     */
    var description: String {
        switch self {
        case .colorful:
            return "colorful"
        case .tealMarble:
            return "tealMarble"
        case .blueMarble:
            return "blueMarble"
        case .yellowMarble:
            return "yellowMarble"
        case .orangeMarble:
            return "orangeMarble"
        }
    }
    
    /**
     The name of each target's model.
     
     Use `Entity.loadModel(named: CollectTargetType.modelName)` to get a Model Entity of the target.
     */
    var modelName: String {
        return self.description
    }
    
    /**
     Color to represent the TraceTarget with.
     */
    var color: UIColor {
        switch self {
        case .colorful:
            return .gray
        case .tealMarble:
            return .systemTeal
        case .blueMarble:
            return .blue
        case .yellowMarble:
            return .yellow
        case .orangeMarble:
            return .orange
        }
    }
    
    /**
     Minimum spawn positions.

     Positive x points to the left. z away from the user.
     */
    var minPosition: SIMD3<Float> {
        switch self {
        case .colorful:
            return SIMD3<Float>(-3, -1, 0)
        case .tealMarble:
            return SIMD3<Float>(0, -1, 1)

        case .blueMarble:
            return SIMD3<Float>(-3, -1, 1)
        case .yellowMarble:
            return SIMD3<Float>(-5, -1, 1)
        case .orangeMarble:
            return SIMD3<Float>(-3, -1, 1)
        }
    }

    /**
     Maximum Spawn position.
     */
    var maxPosition: SIMD3<Float> {
        switch self {
        case .colorful:
            return SIMD3<Float>(0, -1, 3)
        case .tealMarble:
            return SIMD3<Float>(3, -1, 4)
        case .blueMarble:
            return SIMD3<Float>(3, -1, 5)
        case .yellowMarble:
            return SIMD3<Float>(3, -1, 3)
        case .orangeMarble:
            return SIMD3<Float>(3, -1, 3)
        }
    }
    
//    func TapGestureRecognizer() {
//        UIGestureRecognizer
//    }
}

