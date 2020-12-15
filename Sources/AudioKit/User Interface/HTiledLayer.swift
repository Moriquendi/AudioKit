//
//  File.swift
//  
//
//  Created by Michał Śmiałko on 11/12/2020.
//

import Foundation
import QuartzCore

struct TileInfo: Equatable, Hashable {
    let index: Int
    let size: CGSize
    let scale: CGFloat
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(scale)
    }
}

public class HTiledLayer: CALayer {
    
    public var tileSize: CGSize {
        CGSize(width: 100, height: bounds.size.height)
    }
    
    public var scale: CGFloat {
        // tileSize.width * 2^scale >= bounds.size.width
        // 2^scale >= bounds.size.width / tileSize.width
        // scale = log2(...)
        max(1.0, log2(bounds.size.width / tileSize.width).rounded(.up))
    }
    
    public func tilesCountAt(scale: CGFloat) -> Int {
        Int(pow(2, scale.rounded(.up)))
    }
    
    func frameFor(tileInfo: TileInfo) -> CGRect {
        let scaleRatio: CGFloat = 1.0// pow(2.0, tileInfo.scale - scale) - I think?
        
        let width = tileInfo.size.width * scaleRatio
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
        var startIndex = Int((viewport.minX / displayedTileSize.width).rounded(.down))
        startIndex = max(0, startIndex)
        
        var endIndex = Int((viewport.maxX / displayedTileSize.width).rounded(.up) - 1)
        endIndex = min(endIndex, tilesCountAt(scale: scale) - 1)
        
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
