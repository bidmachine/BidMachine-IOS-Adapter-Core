import UIKit
@_implementationOnly import Foundation

@_implementationOnly import StackUIKit
@_implementationOnly import StackNASTKit
@_implementationOnly import StackFoundation
@_implementationOnly import BidMachineBiddingCore
@_implementationOnly import StackProductPresentation

class NASTActionController {
    
    weak var adapter: BiddingAdapterProtocol?
    
    weak var eventController: NASTEventController?
    
    private var _configuration: BidMachineIABConfiguration
    
    private var _info: [String : Any]
    
    private var _gestures: [UITapGestureRecognizer] = []
    
    private var _productPresenter: ProductController
    
    init(_ ad: STKNASTAd, _ configuration: BidMachineIABConfiguration) {
        _configuration = configuration
        _productPresenter = ProductController()
        _info = configuration.storeParams
        _productPresenter.delegate = self
   
        _info[ProductController.clickThroughKey] = ad.clickThrough
    }
    
}

extension NASTActionController {
    
    func invalidate() {
        _gestures.removeAll()
    }
    
    func registerClickableViews(_ views: [UIView]) {
        invalidate()
        views.forEach { view in
            let gesture = _gesture()
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(gesture)
            _gestures.append(gesture)
        }
    }
}
 
@objc extension NASTActionController {
    
    func userInteraction() {
        STKSpinnerScreen.show()
        _productPresenter.present(_productParams)
    }
}

private extension NASTActionController {
    
    var _productParams: Dictionary<String, AnyHashable> {
        _info.compactMapValues { $0 as? AnyHashable }
    }
    
    func _gesture() -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userInteraction))
        gesture.numberOfTouchesRequired = 1
        return gesture
    }
}

extension NASTActionController: ProductControllerDelegate {
    
    func controller(_ controller: ProductController, didFailToPresent error: NSError) {
        STKSpinnerScreen.hide()
    }
    
    func controller(_ controller: ProductController, willPresentProduct parameters: Dictionary<String, AnyHashable>) {
        STKSpinnerScreen.hide()
        eventController?.trackClick()
        adapter?.notifyDelegate{ $1.willPresentScreen($0) }
    }
    
    func controller(_ controller: ProductController, willLeaveApplication parameters: Dictionary<String, AnyHashable>) {
        STKSpinnerScreen.hide()
        eventController?.trackClick()
    }
    
    func controller(_ controller: ProductController, didDismissProduct parameters: Dictionary<String, AnyHashable>) {
        adapter?.notifyDelegate{ $1.didDismissScreen($0) }
    }
}
