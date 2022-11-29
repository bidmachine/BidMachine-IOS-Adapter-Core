@_implementationOnly import Foundation

@_implementationOnly import BidMachine
@_implementationOnly import StackNASTKit
@_implementationOnly import BidMachineApiKit
@_implementationOnly import BidMachineBiddingCore

class NASTNetwork : BiddingNetworkProtocol {
    
    static var adapterName: String = "nast"
    
    static var networkVersion: String = StackNASTKitVersion
    
    static var adapterVersion: String = BidMachineAdapter.adapterVersionPath + "." + BidMachineAdapter.iabVersion
    
    weak var delegate: BiddingNetworkDelegate?
    
    func adapterProvider(_ biddingUnit: BiddingUnit) throws -> BiddingAdapterProviderProtocolType {
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
            throw ErrorProvider.unknown(NASTNetwork.adapterName).badContent.withDescription("Can't create adapter with placement - \(self.type.name)")
        }

        let configuration: BidMachineIABConfiguration
        do {
            configuration = try params.decode(BidMachineIABConfiguration.self)
        } catch {
            throw ErrorProvider.unknown(NASTNetwork.adapterName).badContent.withError("Can't create IAB configuration", error)
        }
        
        guard let nast = try? configuration.adm.JSON() else {
            throw ErrorProvider.unknown(NASTNetwork.adapterName).badContent.withDescription("Can't parse NAST configuration")
        }
        
        var _ad: STKNASTAd?
        let semathore = DispatchSemaphore(value: 0)
        manager.parseAd(fromJSON: nast) { ad, error in
            _ad = ad
            semathore.signal()
        }
        
        semathore.wait()
        guard let _ad = _ad else {
            throw ErrorProvider.unknown(NASTNetwork.adapterName).badContent.withDescription("Can't create NAST ad")
        }
        
        return NASTAdapter(_ad, configuration)
    }
}
