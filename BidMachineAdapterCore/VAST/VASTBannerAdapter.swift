import UIKit
import StackUIKit
import StackVASTKit
import BidMachineApiCore
import BidMachineBiddingCore

class VASTBannerAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _placement: Placement
    
    private let _presenter: STKVASTView
    
    private let _configuration: BidMachineIABConfiguration

    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _placement = placement
        _configuration = configuration
        
        _presenter = STKVASTView(configuration: configuration.vastConfiguration(placement))
        
        super.init()
        
        _presenter.delegate = self
    }
}

extension VASTBannerAdapter {
    
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
    
    var videoStateRouter: BiddingAdapterVideoStateRouter? {
        return self
    }
}

extension VASTBannerAdapter: BiddingAdapterEventStateRouter {
    
    func trackImpression() {
        self.notifyDelegate{ $1.trackImpression() }
    }
}

extension VASTBannerAdapter: BiddingAdapterVideoStateRouter {
    
    func stopPlayVideo() {
        _presenter.pause()
    }
    
    func startPlayVideo() {
        _presenter.resume()
    }
    
    func muteVideo() {
        _presenter.mute()
    }
    
    func unmuteVideo() {
        _presenter.unmute()
    }
}

private extension VASTBannerAdapter {
    
    func _prepareContent() {
        _presenter.load(forVastXML: _configuration.adm.data(using: .utf8))
    }
    
    func _present(_ container: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(_presenter)
        
        _presenter.stk_edgesEqual(container)
        self.notifyDelegate{ $1.didPresent($0) }
    }
}

extension VASTBannerAdapter: STKVASTViewDelegate {
    
    func vastViewReady(_ view: STKVASTView) {
        self.notifyDelegate{ $1.didLoad($0) }
    }
    
    func vastView(_ view: STKVASTView, didFailToLoad error: Error) {
        self.notifyDelegate{ $1.failToLoad($0, BidMachineAdapterError.badContent("Can't load VAST", error)) }
    }
    
    func vastViewDidPresent(_ view: STKVASTView) {
        
    }
    
    func vastViewDidFinish(_ view: STKVASTView) {
        
    }
    
    func vastViewWillLeaveApplication(_ view: STKVASTView) {
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func vastViewWillPresentProductScreen(_ view: STKVASTView) {
        self.notifyDelegate{ $1.willPresentScreen($0) }
        self.notifyDelegate{ $1.didRecieveUserAction($0) }
    }
    
    func vastViewDidDismissProductScreen(_ view: STKVASTView) {
        self.notifyDelegate{ $1.didDismissScreen($0) }
    }
}
