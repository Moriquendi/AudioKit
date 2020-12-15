//
//  File.swift
//  
//
//  Created by Michał Śmiałko on 11/12/2020.
//

import Foundation
import QuartzCore

extension CALayer {
    /*
    public var visibleBounds: CGRect {
        var rect = frame
        var current = self.superlayer
        rect = self.convert(bounds, to: current!)
        
        while current != nil {
            if current!.masksToBounds {
                rect = rect.intersection(current!.bounds)
            }
            
            let old = current
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
    */
}

import Cocoa
extension NSView {
    
    public var visibleBounds: CGRect {
        var rect = frame
        var current = self.superview
        rect = self.convert(bounds, to: current!)
        
        while current != nil {
            if current!.layer?.masksToBounds ?? false {
                rect = rect.intersection(current!.bounds)
            }
            
            let old = current
            if current?.superview == nil {
                break
            }
            
            current = current?.superview
            if current != nil {
                rect = old!.convert(rect, to: current!)
            }
        }
        rect = current!.convert(rect, to: self)
    
        return rect
    }
    
}

