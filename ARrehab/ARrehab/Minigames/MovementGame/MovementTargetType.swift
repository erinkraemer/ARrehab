//
//  MovementTargetType.swift
//  ARrehab
//
//  Created by Erin Kraemer on 12/7/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/**
 Set of MovementTarget types.
 */
enum MovementTargetType {
    case colorful, tealMarble, blueMarble, yellowMarble, orangeMarble
    
    /**
     A list of all the possible target types.
     */
    static var allTypes: [MovementTargetType] = [.colorful, .tealMarble, .blueMarble, .yellowMarble, .orangeMarble]
    
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
     
     Use `Entity.loadModel(named: traceTargetType.modelName)` to get a Model Entity of the target.
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
            return SIMD3<Float>(-3, 0.03, 0)
        case .tealMarble:
            return SIMD3<Float>(0, 0.03, 1)

        case .blueMarble:
            return SIMD3<Float>(-3, 0.03, 1)
        case .yellowMarble:
            return SIMD3<Float>(-5, 0.03, 1)
        case .orangeMarble:
            return SIMD3<Float>(-3, 0.03, 1)
        }
    }

    /**
     Maximum Spawn position.
     */
    var maxPosition: SIMD3<Float> {
        switch self {
        case .colorful:
            return SIMD3<Float>(0, 0.03, 3)
        case .tealMarble:
            return SIMD3<Float>(3, 0.03, 4)
        case .blueMarble:
            return SIMD3<Float>(3, 0.03, 5)
        case .yellowMarble:
            return SIMD3<Float>(3, 0.03, 3)
        case .orangeMarble:
            return SIMD3<Float>(3, 0.03, 3)
        }
    }
}

