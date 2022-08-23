import UIKit
import Foundation
import StackUIKit
import StackNASTKit
import BidMachineBiddingCore

class NASTAdapter: BiddingAdapterProtocol {
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    private let _title: NativeAsset<TitleAssetType>
    
    private let _description: NativeAsset<DescriptionAssetType>
    
    private let _callToAction: NativeAsset<CallToActionAssetType>
    
    private let _icon: NativeAsset<IconAssetType>
    
    private let _image: NativeAsset<ImageAssetType>
    
    private let _adChoice: NativeAsset<AdChoiceAssetType>
    
    private let _video: NativeAsset<VideoAssetType>
    
    private let _mediaController: NASTMediaController
    
    private let _actionController: NASTActionController
    
    private let _eventController: NASTEventController
    
    init(_ ad: STKNASTAd, _ configuration: BidMachineIABConfiguration) {
        _mediaController = NASTMediaController(ad)
        _eventController = NASTEventController(ad)
        _actionController = NASTActionController(ad, configuration)
        
        _title = NativeAsset(ad.title)
        _description = NativeAsset(ad.descriptionText)
        _callToAction = NativeAsset(ad.callToAction)
        _icon = NativeAsset(ad.iconURLString)
        _image = NativeAsset(ad.mainURLString)
        _adChoice = NativeAsset(nil)
        _video = NativeAsset(_mediaController.isVideo)
        
        _mediaController.eventController = _eventController
        _actionController.eventController = _eventController
        _eventController.adapter = self
        _actionController.adapter = self
    }
}

extension NASTAdapter {

    func prepareContent() throws {
        self.notifyDelegate { $1.didLoad($0) }
    }

    func present() throws {
        try _present()
    }

    func invalidate() {
        _mediaController.invalidate()
        _actionController.invalidate()
        self.notifyDelegate { $1.didDismiss($0) }
    }

    var nativeRouter: BiddingAdapterNativeSourceRouterProtocol? {
        return self
    }

    var eventStateRouter: BiddingAdapterEventStateRouter? {
        return self
    }
}

extension NASTAdapter: BiddingAdapterNativeSourceRouterProtocol {
    
    func getAsset<T>(_ type: T.Type) -> NativeAsset<T>? where T : NativeAssetTypeProtocol {
        switch type {
        case is TitleAssetType.Type: return _title as? NativeAsset<T>
        case is DescriptionAssetType.Type: return _description as? NativeAsset<T>
        case is CallToActionAssetType.Type: return _callToAction as? NativeAsset<T>
        case is IconAssetType.Type: return _icon as? NativeAsset<T>
        case is ImageAssetType.Type: return _image as? NativeAsset<T>
        case is AdChoiceAssetType.Type: return _adChoice as? NativeAsset<T>
        case is VideoAssetType.Type: return _video as? NativeAsset<T>
        default: return nil
        }
    }
}

extension NASTAdapter: BiddingAdapterEventStateRouter {
    
    func trackContainerAdded() {
        _eventController.trackContainerAdded()
    }
    
    func trackImpression() {
        _eventController.trackImpression()
    }
    
    func trackClick() {
        _actionController.userInteraction()
    }
}

private extension NASTAdapter {
    
    func _present() throws {
        
        var clickableViews: [UIView] = []
        
        if let title = _title.value, let container = _title.container {
            container.text = title
            clickableViews.append(container)
        }
        
        if let cta = _callToAction.value, let container = _callToAction.container {
            container.text = cta
            clickableViews.append(container)
        }
        
        if let desc = _description.value, let container = _description.container {
            container.text = desc
        }
        
        if let icon = _icon.value, let container = _icon.container {
            container.stkFastImageCache(URL(string: icon))
            clickableViews.append(container)
        }
        
        if let container = _image.container {
            _mediaController.render(container, dataSource?.controller)
        }
        
        _actionController.registerClickableViews(clickableViews)
        self.notifyDelegate { $1.didPresent($0) }
    }
}
