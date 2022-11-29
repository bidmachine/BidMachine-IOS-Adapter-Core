import UIKit

@_implementationOnly import StackUIKit
@_implementationOnly import BidMachine
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiKit
@_implementationOnly import BidMachineBiddingCore

class MRAIDFullscreenAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _placement: Placement
    
    private let _interstitial: STKMRAIDInterstitial
    
    private let _configuration: BidMachineIABConfiguration
    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _interstitial = STKMRAIDInterstitial()
        _placement = placement
        _configuration = configuration
        
        super.init()
    }
}

extension MRAIDFullscreenAdapter {
    
    func prepareContent() throws {
        _interstitial.delegate = self
        _interstitial.loadHTML(_configuration.adm, with: _configuration.mraidConfiguration)
    }
    
    func present(on controller: UIViewController) throws {
        _interstitial.presentAd()
    }
}

extension MRAIDFullscreenAdapter: STKMRAIDInterstitialDelegate {
    
    func didLoadAd(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate { $1.didLoad($0) }
    }
    
    func didExpireAd(_ wrapper: STKMRAIDWrapper) {
        self.notifyDelegate{ $1.didExpiredAdapter($0) }
    }
    
    func didFail(toLoadAd wrapper: STKMRAIDWrapper, withError error: Error) {
        self.notifyDelegate {
            $1.failToLoad($0, ErrorProvider.unknown(MRAIDNetwork.adapterName)
                .noContent.withError("Fail load", error)) }
    }
    
    func didFail(toShowAd wrapper: STKMRAIDWrapper, withError error: Error) {
        self.notifyDelegate {
            $1.failToPresent($0, ErrorProvider.unknown(MRAIDNetwork.adapterName)
                .badContent.withError("Fail present", error)) }
    }
    
    func interstitialDidImpression(_ interstitial: STKMRAIDInterstitial) {
        self.notifyDelegate { $1.didPresent($0) }
        self.notifyDelegate { $1.didTrackImpression($0) }
    }
    
    func interstitialDidAppear(_ interstitial: STKMRAIDInterstitial) {
       
    }
    
    func interstitialDidDissapear(_ interstitial: STKMRAIDInterstitial) {
        if _placement.isRewarded {
            self.notifyDelegate { $1.didRecieveReward($0) }
        }
        self.notifyDelegate { $1.didDismiss($0) }
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

