@_implementationOnly import Foundation

@_implementationOnly import StackVASTKit
@_implementationOnly import BidMachine
@_implementationOnly import BidMachineApiKit
@_implementationOnly import BidMachineBiddingCore

class VASTNetwork : BiddingNetworkProtocol {
    
    static var adapterName: String = "vast"
    
    static var networkVersion: String = StackVASTKitVersion
    
    static var adapterVersion: String = BidMachineAdapter.adapterVersionPath + "." + BidMachineAdapter.iabVersion
    
    weak var delegate: BiddingNetworkDelegate?
    
    func adapterProvider(_ biddingUnit: BiddingUnit) throws -> BiddingAdapterProviderProtocolType {
        return VASTProvider(biddingUnit)
    }
    
    func initializeNetwork(_ biddingNetwork: BiddingNetwork) {
        self.delegate?.didInitialize()
    }
    
    required init() {
        
    }
}

class VASTProvider: BiddingAdapterProviderProtocolType {
    
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
        guard self.type.isVideo == true else {
            throw ErrorProvider.unknown(VASTNetwork.adapterName).badContent.withDescription("Can't create adapter with placement - \(self.type.name)")
        }

        let configuration: BidMachineIABConfiguration
        do {
            configuration = try params.decode(BidMachineIABConfiguration.self)
        } catch {
            throw ErrorProvider.unknown(VASTNetwork.adapterName).badContent.withError("Can't create IAB configuration", error)
        }
        
        let adapter = BidMachineDispatcher.mainSync { _syncAdapter(configuration) }
        guard let adapter = adapter else {
            throw ErrorProvider.unknown(VASTNetwork.adapterName).badContent.withDescription("Can't create adapter")
        }

        return adapter
    }
    
    func _syncAdapter(_ configuration: BidMachineIABConfiguration) -> BiddingAdapterProtocol? {
        switch self.type {
        case .media: return VASTBannerAdapter(self, configuration)
        case .rewarded: return VASTFullscreenAdapter(self, configuration)
        case .interstitial: return VASTFullscreenAdapter(self, configuration)
        default: return nil
        }
    }
}
