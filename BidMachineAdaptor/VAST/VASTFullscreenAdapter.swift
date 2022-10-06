import UIKit

@_implementationOnly import StackVASTKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore

class VASTFullscreenAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _placement: Placement
    
    private let _presenter: STKVASTController
    
    private let _configuration: BidMachineIABConfiguration
    
    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _placement = placement
        _configuration = configuration
        _presenter = STKVASTController(configuration: configuration.vastConfiguration(placement))
        
        super.init()
        
        _presenter.delegate = self
    }
}

extension VASTFullscreenAdapter {
    
    func prepareContent() throws {
        _presenter.load(forVastXML: _configuration.adm.data(using: .utf8))
    }
    
    func present() throws {
        _presenter.present(from: self.dataSource?.controller)
    }
}

extension VASTFullscreenAdapter: STKVASTControllerDelegate {
    
    
    func vastControllerReady(_ controller: STKVASTController) {
        self.notifyDelegate { $1.didLoad($0) } 
    }
    
    func vastControllerDidExpire(_ controller: STKVASTController) {
        self.notifyDelegate{ $1.didExpiredAdapter($0) }
    }
    
    func vastController(_ controller: STKVASTController, didFailToLoad error: Error) {
        self.notifyDelegate{ $1.failToLoad($0, BidMachineAdapterError.badContent("Can't load VAST", error)) }
    }
    
    func vastController(_ controller: STKVASTController, didFailWhileShow error: Error) {
        var wrappedError = BidMachineAdapterError.badContent("Can't present VAST", error)
        if (error as NSError).code == 201 {
            wrappedError = BidMachineAdapterError.timeouted("Can't present VAST", error)
        }

        self.notifyDelegate { $1.failToPresent($0, wrappedError) }
    }
    
    func vastControllerDidPresent(_ controller: STKVASTController) {
        self.notifyDelegate { $1.didPresent($0) }
        
    }
    
    func vastControllerDidFinish(_ controller: STKVASTController) {
        if _placement.isRewarded {
            self.notifyDelegate { $1.didRecieveReward($0) }
        }
    }
    
    func vastControllerDidImpression(_ controller: STKVASTController) {
        self.notifyDelegate { $1.trackImpression() }
    }
    
    func vastControllerWillLeaveApplication(_ controller: STKVASTController) {
        self.notifyDelegate { $1.didRecieveUserAction($0) }
    }
    
    func vastControllerWillPresentProductScreen(_ controller: STKVASTController) {
        self.notifyDelegate { $1.willPresentScreen($0) }
        self.notifyDelegate { $1.didRecieveUserAction($0) }
    }
    
    func vastControllerDidDismissProductScreen(_ controller: STKVASTController) {
        self.notifyDelegate { $1.didDismissScreen($0) }
    }
    
    func vastControllerDidDismiss(_ controller: STKVASTController) {
        self.notifyDelegate { $1.didDismiss($0) }
    }
}
