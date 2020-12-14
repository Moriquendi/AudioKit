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

    // TODO: Move to HTiledLayer
    private var cachedTiles = NSCache<NSString, WaveformTile>()
    // We need this because NSCache doesn't allow enumerating on its keys/objects
    private var weakTilesArray = NSHashTable<WaveformTile>()
    
    // MARK: - Public functions
    
    public override var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            print("Did set bounds: \(bounds)")
            self.reloadTilesIfNeeded()
        }
    }
    
    public override var position: CGPoint {
        didSet {
            guard oldValue != position else { return }
            print("Did set position: \(position)")
            self.reloadTilesIfNeeded()
        }
    }
    
    public override var transform: CATransform3D {
        didSet {
            guard !CATransform3DEqualToTransform(oldValue, transform) else { return }
            print("Did set new transform.")
            self.reloadTilesIfNeeded()
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
        reloadTilesIfNeeded()
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
        guard !visibleBounds.isEmpty && !visibleBounds.isInfinite else { return }
        
        let newTilesInfo = tilesFor(viewport: visibleBounds)
        
        let oldTiles = tiles.sorted { $0.info.index < $1.info.index }
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


