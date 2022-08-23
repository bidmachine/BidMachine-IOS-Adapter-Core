import Foundation
import StackNASTKit
import StackFoundation
import BidMachineBiddingCore

class NASTEventController {
    
    weak var adapter: BiddingAdapterProtocol?
    
    private let _clickTracking: [URL]
    
    private let _finishTracking: [URL]
    
    private let _impressionTracking: [URL]
    
    init(_ ad: STKNASTAd) {
        _clickTracking = ad.clickTrackers ?? []
        _finishTracking = ad.finishTrackers ?? []
        _impressionTracking = ad.impressionTrackers ?? []
    }
}

extension NASTEventController: BiddingAdapterEventStateRouter {
    
    func trackContainerAdded() {
        adapter?.notifyDelegate { $1.trackContainerAdded() }
    }
    
    func trackImpression() {
        STKThirdPartyEventTracker.sendTrackingEvents(_impressionTracking)
        adapter?.notifyDelegate { $1.trackImpression() }
    }
    
    func trackClick() {
        STKThirdPartyEventTracker.sendTrackingEvents(_clickTracking)
        adapter?.notifyDelegate { $1.didRecieveUserAction($0) }
    }
}
