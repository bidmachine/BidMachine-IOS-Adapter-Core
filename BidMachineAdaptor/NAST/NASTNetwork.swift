@_implementationOnly import Foundation

@_implementationOnly import BidMachine
@_implementationOnly import StackNASTKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import BidMachineBiddingCore

class NASTNetwork : BiddingNetworkProtocol {
    
    static var adapterName: String = "nast"
    
    static var adapterVersion: String = BidMachineAdapter.adapterVersionPath + BidMachineAdapter.iabVersion
    
    static var networkVersion: String = StackNASTKitVersion
    
    weak var delegate: BiddingNetworkDelegate?
    
    func adapterProvider(_ biddingUnit: BiddingUnit) -> BiddingAdapterProviderProtocolType? {
        return NASTProvider(biddingUnit)
    }
    
    func initializeNetwork(_ biddingNetwork: BiddingNetwork) {
        self.delegate?.didInitialize()
    }
    
    required init() {
        
    }
}

class NASTProvider: BiddingAdapterProviderProtocolType {
    
    private let _unit: BiddingUnit
    
    private let _manager: STKNASTManager
    
    weak var delegate: BiddingAdapterProviderInfoDelegate?
    
    func collectBiddingInfo() {
        self.delegate?.didCollectBiddingInfo([:])
    }
    
    func displayAdapter(_ params: BiddingParams) throws -> BiddingAdapterProtocol {
        return try _unit.info.placement.adapter(params, _manager)
    }
    
    fileprivate init(_ unit: BiddingUnit) {
        _unit = unit
        _manager = STKNASTManager()
    }
}

fileprivate extension Placement {
    
    func adapter(_ params: BiddingParams, _ manager: STKNASTManager) throws -> BiddingAdapterProtocol {
        guard self.type.isNative == true else {
            throw BidMachineAdapterError.badContent("Can't create adapter with placement - \(self.type.name)")
        }

        guard let configuration = try? params.decode(BidMachineIABConfiguration.self) else {
            throw BidMachineAdapterError.badContent("Can't create IAB configuration")
        }
        
        guard let nast = try? configuration.adm.JSON() else {
            throw BidMachineAdapterError.badContent("Can't parse NAST configuration")
        }
        
        var _ad: STKNASTAd?
        let semathore = DispatchSemaphore(value: 0)
        manager.parseAd(fromJSON: nast) { ad, error in
            _ad = ad
            semathore.signal()
        }
        
        semathore.wait()
        guard let _ad = _ad else {
            throw BidMachineAdapterError.badContent("Can't create NAST ad")
        }
        
        return NASTAdapter(_ad, configuration)
    }
}
