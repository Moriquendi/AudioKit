// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CoreGraphics
import QuartzCore

public struct WaveformDataSlice {
    let data: [Float]
    let rect: CGRect
    
    public init(data: [Float],
                rect: CGRect) {
        self.data = data
        self.rect = rect
    }
}

/// A CAShapeLayer rendering of a mono waveform. Can be updated on any thread.
public class WaveformLayer: CALayer {

    /// controls whether to use the default CoreAnimation actions or not for property transitions
    public var allowActions: Bool = true

    /// Mirrored is the traditional DAW display
    @objc public var isMirrored: Bool = true
    
    @objc public var drawSampleMarkers: Bool = false
    
    private var _data: WaveformDataSlice? {
        didSet { setNeedsDisplay() }
    }
    /// Array of float values
    
    public var data: WaveformDataSlice? {
        get {
            return _data
        }
        set {
            guard let newValue = newValue else {
                _data = nil
                return
            }
            // validate data
            for value in newValue.data where !value.isFinite {
                return
            }

            _data = newValue
        }
    }

    /// Does this contain any information
    public var isEmpty: Bool { data?.data.isEmpty ?? true }

    //
    // Some properties are marked with @objc
    // so that some of the CALayers methods are called for them.
    // Specifically, "needsDisplay(forKey key: String) -> Bool"
    //
    @objc public var absmax: Double = 1.0
    @objc public var strokeColor: CGColor?
    @objc public var lineWidth: CGFloat = 0.5 // default if stroke is used, otherwise this does nothing
    @objc public var fillColor: CGColor? = CrossPlatformColor.black.cgColor
    
    
    /// Initialize with all parameters
    /// - Parameters:
    ///   - data: Array of floats
    ///   - size: Layer size
    ///   - fillColor: Fill Color
    ///   - strokeColor: Stroke color
    ///   - backgroundColor: Backround color
    ///   - opacity: Opacity
    ///   - isMirrored: Whether or not to display mirrored
    public convenience init(data: WaveformDataSlice,
                            absmax: Double = 1.0,
                            size: CGSize? = nil,
                            fillColor: CGColor? = nil,
                            strokeColor: CGColor? = nil,
                            backgroundColor: CGColor? = nil,
                            opacity: Float = 1,
                            isMirrored: Bool = false) {
        self.init()
        self.data = data
        self.isMirrored = isMirrored
        self.absmax = absmax
        
        self.opacity = opacity
        self.backgroundColor = backgroundColor
        
        self.strokeColor = strokeColor
        lineWidth = 0.5 // default if stroke is used, otherwise this does nothing
        self.fillColor = fillColor ?? CrossPlatformColor.black.cgColor
        
        masksToBounds = false
        isOpaque = false
        drawsAsynchronously = true
        shadowColor = CrossPlatformColor.black.cgColor
        shadowOpacity = 0.4
        shadowOffset = CGSize(width: 1, height: -1)
        shadowRadius = 2.0
    }

    // MARK: - Public Functions
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case "strokeColor", "fillColor", "absmax", "isMirrored", "lineWidth", "drawSampleMarkers":
            return true
        default:
            return super.needsDisplay(forKey: key)
        }
    }
    
    /// controls whether to use the default CoreAnimation actions or not for property transitions
    override public func action(forKey event: String) -> CAAction? {
        return allowActions ? super.action(forKey: event) : nil
    }

    /// Remove all data
    public func dispose() {
        data = nil
    }

    // MARK: - Private Functions
    
    public override func draw(in ctx: CGContext) {
        guard let (linePath, markersPath) = createPath(at: bounds.size) else {
            return
        }
        
        
        // TODO:
        // Disable antialias?
        // ctx.setShouldAntialias(false)
        ctx.interpolationQuality = .none
        
        if let strokeColor = self.strokeColor {
            ctx.addPath(linePath)
            ctx.setLineWidth(lineWidth)
            ctx.setStrokeColor(strokeColor)
            ctx.strokePath()
        }
        if let fillColor = self.fillColor {
            
            if !drawSampleMarkers {
                ctx.addPath(linePath)
                ctx.setFillColor(fillColor)
                ctx.fillPath()
            }
            
            if let markersPath = markersPath {
                ctx.addPath(markersPath)
                ctx.setFillColor(fillColor)
                ctx.fillPath()
            }
        }
    }

    private func createPath(at size: CGSize) -> (CGPath, CGPath?)? {
        guard let data = data else { return nil }
        let table = data.data
        guard table.isNotEmpty,
              size != CGSize.zero else {
            return nil
        }

        // TODO: Kinda 'meh' and unsafe
        let dataRect = convert(data.rect, from: superlayer)
        let half: CGFloat = isMirrored ? 2 : 1
        let halfHeight = size.height / half
        
        let halfPath = CGMutablePath()
        let markersMutablePath = CGMutablePath()
        
        let startPoint = CGPoint(x: dataRect.minX, y: 0)
        halfPath.move(to: startPoint)

        let theWidth = max(1, Int(size.width))
        // TODO: Tmp, draw all points for now.
        //let strideWidth = max(1, table.count / theWidth)
        let strideWidth = 1
        let sampleDrawingVScale = halfHeight / CGFloat(absmax * 0.85)
        
        
        
        for i in stride(from: 0, to: table.count, by: strideWidth) {
            let xJump = CGFloat(dataRect.size.width) / CGFloat(table.count)
            let x = startPoint.x + CGFloat(i) * xJump
            let y = CGFloat(table[i]) * sampleDrawingVScale

            halfPath.addLine(to: CGPoint(x: x, y: y))
            
            
            // Drawing rect on each sample
            if drawSampleMarkers {
                var sampleRect = CGRect(width: 8, height: 8)
                sampleRect.origin = CGPoint(x: x + 4, y: y - 4)
                markersMutablePath.addEllipse(in: sampleRect)
            }
        }
        halfPath.addLine(to: CGPoint(x: dataRect.maxX, y: 0))
        
        // If mirrored just copy the path and flip it upside down
        let linePath: CGPath
        var markersPath: CGPath?
        if isMirrored {
            linePath = halfPath.mirrored(halfHeight: halfHeight)
            markersPath = markersMutablePath.mirrored(halfHeight: halfHeight)
        } else {
            linePath = halfPath
        }
                
        return (linePath, markersPath)
    }
    
}

extension CGPath {
    
    func mirrored(halfHeight: CGFloat) -> CGPath {
        let path = CGMutablePath()
        
        var xf: CGAffineTransform = .identity
        xf = xf.translatedBy(x: 0.0, y: halfHeight)
        path.addPath(self, transform: xf)

        xf = xf.scaledBy(x: 1.0, y: -1)
        
        if let copy = self.copy(using: &xf) {
            path.addPath(copy)
        }
        return path
    }
    
}
