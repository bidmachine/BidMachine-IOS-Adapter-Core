@_implementationOnly import Foundation

@_implementationOnly import BidMachine
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore


class MRAIDNetwork : BiddingNetworkProtocol {
    
    static var adapterName: String = "mraid"
    
    static var adapterVersion: String = BidMachineAdapter.adapterVersionPath + ".0"
    
    static var networkVersion: String = StackMRAIDKitVersion
    
    weak var delegate: BiddingNetworkDelegate?
    
    func adapterProvider(_ biddingUnit: BiddingUnit) -> BiddingAdapterProviderProtocolType? {
        return MRAIDProvider(biddingUnit)
    }
    
    func initializeNetwork(_ biddingNetwork: BiddingNetwork) {
        self.delegate?.didInitialize()
    }
    
    required init() {
        
    }
}

class MRAIDProvider: BiddingAdapterProviderProtocolType {
    
    private let _unit: BiddingUnit
    
    weak var delegate: BiddingAdapterProviderInfoDelegate?
    
    func collectBiddingInfo() {
        self.delegate?.didCollectBiddingInfo([:])
    }
    
    func displayAdapter(_ params: BiddingParams) throws -> BiddingAdapterProtocol {
        return try _unit.info.placement.adapter(params)
    }
    
    fileprivate init(_ unit: BiddingUnit) {
        _unit = unit
    }
}

fileprivate extension Placement {
    
    func adapter(_ params: BiddingParams) throws -> BiddingAdapterProtocol {
        guard self.type.isStatic == true else {
            throw BidMachineAdapterError.badContent("Can't create adapter with placement - \(self.type.name)")
        }

        guard let configuration = try? params.decode(BidMachineIABConfiguration.self) else {
            throw BidMachineAdapterError.badContent("Can't create IAB configuration")
        }
        
        let adapter = BidMachineSemaphore.mainSync { _syncAdapter(configuration) }
        guard let adapter = adapter else {
            throw BidMachineAdapterError.badContent("Can't create adapter")
        }

        return adapter
    }
    
    func _syncAdapter(_ configuration: BidMachineIABConfiguration) -> BiddingAdapterProtocol? {
        switch self.type {
        case .banner: return MRAIDBannerAdapter(self, configuration)
        case .rewarded: return MRAIDFullscreenAdapter(self, configuration)
        case .interstitial: return MRAIDFullscreenAdapter(self, configuration)
        default: return nil
        }
    }
}