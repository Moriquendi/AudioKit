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
    
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        isDirty = false
    }
    
    override public func action(forKey event: String) -> CAAction? {
        // Disable all default transitions
        // TODO: Maybe allow some transitions?
        return nil
    }
    
    private func setup() {
        contentsGravity = .resize
        
        // Debugging
        // borderWidth = 1
        // borderColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    }
}
