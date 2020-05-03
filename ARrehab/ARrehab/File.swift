//
//  File.swift
//  ARrehab
//
//  Created by Eric Wang on 5/2/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
