//
//  File.swift
//  
//
//  Created by Michał Śmiałko on 11/12/2020.
//

import Foundation
import QuartzCore

class WaveformTile: WaveformLayer {
    
    let info: TileInfo
    var isDirty = true
    
    // TODO: init(layer: Any) is not implemented
    // and so it will crash if we try to animate this layer.
    // Maybe consider adding this in the future.
    init(info: TileInfo) {
        self.info = info
        
        super.init()
        
        contentsScale = 2.0
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
//        print("Mark to display \(info.index) | Data: \(data?.data.count ?? 0)")
        isDirty = false
    }
    
    override public func action(forKey event: String) -> CAAction? {
        // Disable all default transitions
        // TODO: Maybe allow some transitions?
        return nil
    }
    
    private func setup() {
        contentsGravity = .resize
        
        // TODO: Would any of these boost the performance?
        //magnificationFilter = .trilinear
        //shouldRasterize = true
        //allowsEdgeAntialiasing = false
        
        // Debugging
         //borderWidth = 1
         //borderColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    }
}
