import UIKit

@_implementationOnly import StackUIKit
@_implementationOnly import BidMachine
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore

class MRAIDBannerAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _banner: STKMRAIDBanner
    
    private let _placement: Placement
    
    private let _configuration: BidMachineIABConfiguration
    
    private var _isAdOnScreen: Bool = false
    
    private var _isMraidOnScreen: Bool = false
    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _banner = STKMRAIDBanner()
        _placement = placement
        _configuration = configuration
        
        super.init()
    }
}

extension MRAIDBannerAdapter {
    
    func prepareContent() throws {
        _prepareContent()
    }
    
    func present() throws {
        guard let container = self.dataSource?.container else {
            throw BidMachineAdapterError.noContent("Container can't be nll")
        }
        _present(container)
    }
    
    func invalidate() {
        _banner.removeFromSuperview()
        self.notifyDelegate{ $1.didDismiss($0) }
    }
    
    var eventStateRouter: BiddingAdapterEventStateRouter? {
        return self
    }
}

extension MRAIDBannerAdapter: BiddingAdapterEventStateRouter {
    
    func trackImpression() {
        _isAdOnScreen = true
        _trackImpressionIfNeeded()
    }
    
    func _trackImpressionIfNeeded() {
        if _isAdOnScreen && _isMraidOnScreen {
            self.notifyDelegate{ $1.trackImpression() }
        }
    }
}

private extension MRAIDBannerAdapter {
    
    func _prepareContent() {
        _banner.delegate = self
        _banner.loadHTML(_configuration.adm, with: _configuration.mraidConfiguration)
    }
    
    func _present(_ container: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(_banner)
        
        _banner.stk_edgesEqual(container)
        
        self.notifyDelegate{ $1.didPresent($0) }
    }
}

extension MRAIDBannerAdapter: STKMRAIDBannerDelegate {
    
    func didLoadAd(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.didLoad($0) }
    }
    
    func didExpireAd(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.didExpiredAdapter($0) }
    }
    
    func didFail(toLoadAd wrapper: STKMRAIDWrapper, withError error: Error) {
        self.notifyDelegate{ $1.failToLoad($0, BidMachineAdapterError.badContent("Can't load MRAID", error)) }
    }
    
    func didFail(toShowAd wrapper: STKMRAIDWrapper, withError error: Error) {
        self.notifyDelegate{ $1.failToPresent($0, BidMachineAdapterError.badContent("Can't present MRAID", error)) }
    }
    
    func bannerDidShow(_ banner: STKMRAIDBanner) {
        _isMraidOnScreen = true
        _trackImpressionIfNeeded()
    }
    
    func wrapperWillLeaveApplication(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func wrapperWillPresentProductScreen(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.willPresentScreen($0) }
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func wrapperDidDismissProductScreen(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.didDismissScreen($0) }
    }
    
    func rootViewController() -> UIViewController? {
        return self.dataSource?.controller
    }
}
