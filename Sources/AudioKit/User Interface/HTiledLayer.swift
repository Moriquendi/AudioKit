//
//  File.swift
//  
//
//  Created by Michał Śmiałko on 11/12/2020.
//

import Foundation
import QuartzCore

public struct TileInfo: Equatable {
    let index: Int
    let size: CGSize
    let scale: CGFloat
}

public class HTiledLayer: CALayer {
    
    public var tileSize: CGSize {
        CGSize(width: 100, height: bounds.size.height)
    }
    
    public var scale: CGFloat {
        // tileSize.width * 2^scale >= bounds.size.width
        // 2^scale >= bounds.size.width / tileSize.width
        // scale = log2(...)
        log2(bounds.size.width / tileSize.width).rounded(.up)
    }
    
    public func tilesCountAt(scale: CGFloat) -> Int {
        Int(pow(2, scale.rounded(.up)))
    }
    
    func frameFor(tileInfo: TileInfo) -> CGRect {
        let width = tileInfo.size.width
        let x = CGFloat(tileInfo.index) * width
        
        return CGRect(x: x,
                      y: 0,
                      width: width,
                      height: bounds.size.height)
    }
    
    var displayedTileSize: CGSize {
        let w = bounds.size.width / CGFloat(tilesCountAt(scale: scale))
        return CGSize(width: w, height: tileSize.height)
    }
    
    func tilesFor(viewport: CGRect) -> [TileInfo] {
        let startIndex = Int((viewport.minX / displayedTileSize.width).rounded(.down))
        let endIndex = Int((viewport.maxX / displayedTileSize.width).rounded(.up) - 1)
        
        let scale = self.scale
        var all: [TileInfo] = []
        for i in startIndex...endIndex {
            let info = TileInfo(index: i,
                                size: tileSize,
                                scale: scale)
            all.append(info)
        }
        return all
    }
    
    override public func action(forKey event: String) -> CAAction? {
        // Disable all default transitions.
        // TODO: Give option to enable transitions for some keys.
        return nil
    }
}
