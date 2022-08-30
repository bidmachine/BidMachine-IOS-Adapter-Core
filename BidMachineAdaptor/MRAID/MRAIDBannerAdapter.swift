import UIKit

@_implementationOnly import StackUIKit
@_implementationOnly import BidMachine
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore

class MRAIDBannerAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _ad: STKMRAIDAd
    
    private let _placement: Placement
    
    private let _presenter: STKMRAIDViewPresenter
    
    private let _configuration: BidMachineIABConfiguration
    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _ad = STKMRAIDAd()
        _placement = placement
        _configuration = configuration
        _presenter = STKMRAIDViewPresenter(configuration: configuration.mraidConfiguration)
        
        super.init()
        
        _ad.delegate = self
        _presenter.delegate = self
        _ad.service.configuration.registerServices([kMRAIDSupportsInlineVideo, kMRAIDSupportsLogging, kMRAIDMeasure])
        _ad.service.configuration.partnerName = BidMachineSdk.partnerName
        _ad.service.configuration.partnerVersion = BidMachineSdk.partnerVersion
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
        _presenter.removeFromSuperview()
        self.notifyDelegate{ $1.didDismiss($0) }
    }
    
    var eventStateRouter: BiddingAdapterEventStateRouter? {
        return self
    }
}

extension MRAIDBannerAdapter: BiddingAdapterEventStateRouter {
    
    func trackImpression() {
        self.notifyDelegate{ $1.trackImpression() }
    }
}

private extension MRAIDBannerAdapter {
    
    func _prepareContent() {
        _ad.loadHTML(_configuration.adm)
    }
    
    func _present(_ container: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(_presenter)
        
        _presenter.stk_edgesEqual(container)
        _presenter.present(_ad)
        
        self.notifyDelegate{ $1.didPresent($0) }
    }
}

extension MRAIDBannerAdapter: STKMRAIDAdDelegate {
    
    func didLoad(_ ad: STKMRAIDAd) {
        self.notifyDelegate{ $1.didLoad($0) }
    }
    
    func didFail(toLoad ad: STKMRAIDAd, withError error: Error) {
        self.notifyDelegate{ $1.failToLoad($0, BidMachineAdapterError.badContent("Can't load MRAID", error)) }
    }
    
    func ad(_ ad: STKMRAIDAd, shouldProcessNavigationWith URL: URL) -> Bool {
        return true
    }
}

extension MRAIDBannerAdapter: STKMRAIDViewPresenterDelegate {
    
    func presenterWillLeaveApplication(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func presenterWillPresentProductScreen(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate{ $1.willPresentScreen($0) }
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func presenterDidDismissProductScreen(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate{ $1.didDismissScreen($0) }
    }
    
    func presenterRootViewController() -> UIViewController? {
        return self.dataSource?.controller
    }
}
