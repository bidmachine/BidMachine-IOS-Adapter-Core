@_implementationOnly import Foundation

@_implementationOnly import StackNASTKit
@_implementationOnly import StackRichMedia
@_implementationOnly import StackVASTAssets

fileprivate class NASTRichMediaAsset: STKVASTAsset, STKRichMediaAsset {
    
    var placeholderImageURL: URL?
}

class NASTMediaController: NSObject {
    
    weak var eventController: NASTEventController?
    
    private let _asset: NASTRichMediaAsset
    
    private lazy var _player: STKRichMediaPlayerView = {
        let player = STKRichMediaPlayerView()
        player.delegate = self
        return player
    }()
    
    init(_ ad: STKNASTAd) {
        var error: NSError?
        let asset = NASTRichMediaAsset(inLine: ad.vastInLineModel, error: &error)
        _asset = error == nil ? asset : NASTRichMediaAsset()
        
        if let image = ad.mainURLString {
            _asset.placeholderImageURL = URL(string: image)
        }
        
        super.init()
    }
}

extension NASTMediaController {
    
    var isVideo: Bool {
        _asset.contentURL != nil
    }
    
    func invalidate() {
        _player.removeFromSuperview()
    }
    
    func render(_ container: UIView, _ controller: UIViewController?) {
        invalidate()
        _player.rootViewController = controller
        _player.stk_edgesEqual(container)
        _player.play(_asset)
    }
}

extension NASTMediaController: STKRichMediaPlayerViewDelegate {
    
    func playerViewWillPresentFullscreen(_ playerView: STKRichMediaPlayerView) {
        
    }
    
    func playerViewDidDissmissFullscreen(_ playerView: STKRichMediaPlayerView) {
        
    }
    
    func playerViewWillShowProduct(_ playerView: STKRichMediaPlayerView) {
        
    }
    
    func playerViewDidInteract(_ playerView: STKRichMediaPlayerView) {
        eventController?.trackClick()
    }
}
