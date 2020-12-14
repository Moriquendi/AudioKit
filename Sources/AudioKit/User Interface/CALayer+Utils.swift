//
//  File.swift
//  
//
//  Created by Michał Śmiałko on 11/12/2020.
//

import Foundation
import QuartzCore

extension CALayer {
    
    public var visibleBounds: CGRect {
        var rect = frame
        var current = self.superlayer
        rect = self.convert(bounds, to: current!)
        
        while current != nil {
            if current!.masksToBounds {
                rect = rect.intersection(current!.bounds)
            }
            
            var old = current
            if current?.superlayer == nil {
                break
            }
            
            current = current?.superlayer
            if current != nil {
                rect = old!.convert(rect, to: current!)
            }
        }
        rect = current!.convert(rect, to: self)
    
        return rect
    }
    
}

