import UIKit

@_implementationOnly import StackUIKit
@_implementationOnly import BidMachine
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore

class MRAIDFullscreenAdapter: NSObject, BiddingAdapterProtocol {
    
    private let _ad: STKMRAIDAd
    
    private let _placement: Placement
    
    private let _presenter: STKMRAIDInterstitialPresenter
    
    private let _configuration: BidMachineIABConfiguration
    
    
    weak var delegate: BiddingAdapterDelegate?
    
    weak var dataSource: BiddingAdapterDataSource?
    
    init(_ placement: Placement, _ configuration: BidMachineIABConfiguration) {
        _ad = STKMRAIDAd()
        _placement = placement
        _configuration = configuration
        _presenter = STKMRAIDInterstitialPresenter(configuration: configuration.mraidConfiguration)
        
        super.init()

        _ad.delegate = self
        _presenter.delegate = self
        _ad.service.configuration.registerServices([kMRAIDSupportsInlineVideo, kMRAIDSupportsLogging, kMRAIDMeasure])
        _ad.service.configuration.partnerName = BidMachineSdk.partnerName
        _ad.service.configuration.partnerVersion = BidMachineSdk.partnerVersion
        
        _ad.configuration.appendTimeout(_configuration.adMarkupLoadingTimeout ?? 0)
    }
}

extension MRAIDFullscreenAdapter {
    
    func prepareContent() throws {
        _ad.loadHTML(_configuration.adm)
    }
    
    func present() throws {
        _presenter.present(_ad)
    }
}

extension MRAIDFullscreenAdapter: STKMRAIDAdDelegate {
    
    func didLoad(_ ad: STKMRAIDAd) {
        self.notifyDelegate { $1.didLoad($0) }
    }
    
    func didFail(toLoad ad: STKMRAIDAd, withError error: Error) {
        self.notifyDelegate{ $1.failToLoad($0, BidMachineAdapterError.badContent("Can't load MRAID", error)) }
    }
    
    func ad(_ ad: STKMRAIDAd, shouldProcessNavigationWith URL: URL) -> Bool {
        return true
    }
}

extension MRAIDFullscreenAdapter: STKMRAIDInterstitialPresenterDelegate {
    
    func presenterDidAppear(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate { $1.didPresent($0) }
        self.notifyDelegate { $1.trackImpression() }
    }
    
    func presenterDidDisappear(_ presenter: STKMRAIDPresenter) {
        if _placement.isRewarded {
            self.notifyDelegate { $1.didRecieveReward($0) }
        }
        self.notifyDelegate { $1.didDismiss($0) }
    }
    
    func presenterFail(toPresent presenter: STKMRAIDPresenter, withError error: Error) {
        self.notifyDelegate { $1.failToPresent($0, BidMachineAdapterError.badContent("Can't present MRAID", error)) }
    }
    
    func presenterWillLeaveApplication(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate { $1.didRecieveUserAction($0) }
    }
    
    func presenterWillPresentProductScreen(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate { $1.willPresentScreen($0) }
        self.notifyDelegate { $1.didRecieveUserAction($0) }
    }
    
    func presenterDidDismissProductScreen(_ presenter: STKMRAIDPresenter) {
        self.notifyDelegate { $1.didDismissScreen($0) }
    }
    
    func presenterRootViewController() -> UIViewController? {
        return self.dataSource?.controller
    }
}
