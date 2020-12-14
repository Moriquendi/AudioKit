// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import QuartzCore

#if os(macOS)
    import AppKit
    public typealias CrossPlatformColor = NSColor
#else
    import UIKit
    public typealias CrossPlatformColor = UIColor
#endif


public protocol WaveformDataSource: class {
    func waveform(_ waveform: Waveform, dataFor rect: CGRect) -> [Float]?
}

public class Waveform: HTiledLayer {
    
    public weak var dataSource: WaveformDataSource?
        
    public var waveformColor: CGColor = CrossPlatformColor.black.cgColor {
        didSet { markAsDirty(rect: bounds) }
    }
    
    // Set if known in advance.
    // Otherwise will be calculated as the tiles are loaded.
    public var absmax: Double = 0.0
    
    private var tiles: [WaveformTile] {
        sublayers?.compactMap { $0 as? WaveformTile } ?? []
    }

    private var cachedTiles = NSCache<NSString, WaveformTile>()
    // We need this because NSCache doesn't allow enumerating on its keys/objects
    private var weakTilesArray = NSHashTable<WaveformTile>()
    
    // MARK: - Public functions
    
    public override var bounds: CGRect {
        didSet {
//            print("Did set bounds: \(bounds)")
            reloadTilesIfNeeded()
        }
    }
    
    public override var frame: CGRect {
        didSet {
//            print("Did set frame: \(frame)")
            reloadTilesIfNeeded()
        }
    }
        
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        //print("Layout: \(bounds)")
        //
        // Move tiles layout logic to HTiledLayer
        //
        for tile in tiles {
            let frame = frameFor(tileInfo: tile.info)
            tile.frame = frame
        }
        
        displayDirtyLayersInVisibleBounds()
    }
    
    public func markAsDirty(rect: CGRect) {
        let all = weakTilesArray.allObjects + tiles
        all.forEach {
            if rect.intersects($0.frame) {
                $0.isDirty = true
            }
        }

        displayDirtyLayersInVisibleBounds()
    }
    
    public func visibleBoundsDidChange() {
        displayDirtyLayersInVisibleBounds()
    }
    
    private func displayDirtyLayersInVisibleBounds() {
        let visibleBounds = self.visibleBounds
        for tile in tiles {
            if tile.isDirty && visibleBounds.intersects(tile.frame) {
                //print("Mark to display \(tile.info.index)")
                
                let data = dataSource?.waveform(self, dataFor: tile.frame)
                absmax = max(absmax, Double(data?.max() ?? 0.0))
                tile.absmax = absmax
                tile.table = data
                tile.fillColor = waveformColor
                tile.setNeedsDisplay()
            }
        }
    }
    
    private func reloadTilesIfNeeded() {
        guard !bounds.isEmpty else { return }
        
        
        let newTilesInfo = tilesFor(viewport: bounds)
        
        let oldTiles = tiles
        let oldInfos = oldTiles.map { $0.info }
        
        let diff = newTilesInfo.difference(from: oldInfos)
        
        if !diff.isEmpty {
            print("Reloading tiles at scale=\(scale). Changes: \(diff.count)")
        }
        
        for change in diff {
            switch change {
            case .insert(_, let tileInfo, _):
                let tile: WaveformTile
                
                let cacheKey = "\(tileInfo.hashValue)" as NSString
                if let cachedTile = cachedTiles.object(forKey: cacheKey) {
                    tile = cachedTile
                } else {
                    tile = WaveformTile(info: tileInfo)
                    tile.autoresizingMask = []
                    cachedTiles.setObject(tile, forKey: cacheKey)
                    weakTilesArray.add(tile)
                }
            
                addSublayer(tile)
            case .remove(let offset, _, _):
                oldTiles[offset].removeFromSuperlayer()
            }
        }
    }
    
}


