@_implementationOnly import Foundation

@_implementationOnly import StackProductPresentation

struct BidMachineStoreModel: Decodable {
    
    struct FidelitiesModel: Decodable {
        
        let fidelity: UInt64
        
        let signature: String
        
        let nonce: String
        
        let timestamp: String
    }
    
    let version: String
    
    let network: String
    
    let campaign: String
    
    let itunesitem: String
    
    let nonce: String
    
    let sourceapp: String
    
    let timestamp: String
    
    let signature: String
    
    let fidelities: [FidelitiesModel]?
}

extension BidMachineStoreModel {
    
    var iabJson: [String : Any] {
        var json: [String : Any] = [:]
        json[ProductController.adNetworkVersionKey] = self.version
        json[ProductController.adNetworkIdentifierKey] = self.network
        json[ProductController.adNetworkCampaignIdentifierKey] = self.campaign
        json[ProductController.itemIdentifierKey] = self.itunesitem
        json[ProductController.adNetworkNonceKey] = self.nonce
        json[ProductController.adNetworkSourceAppStoreIdentifierKey] = self.sourceapp
        json[ProductController.adNetworkTimestampKey] = self.timestamp
        json[ProductController.adNetworkAttributionSignatureKey] = self.signature
        json[ProductController.adNetworkFidelitiesKey] = self.fidelities.flatMap{ $0.compactMap{ $0.iabJson } }
        return json
    }
    
}

extension BidMachineStoreModel.FidelitiesModel {
    
    var iabJson: [String : Any] {
        var json: [String : Any] = [:]
        json[ProductController.adNetworkFidelityKey] = self.fidelity
        json[ProductController.adNetworkAttributionSignatureKey] = self.signature
        json[ProductController.adNetworkNonceKey] = self.nonce
        json[ProductController.adNetworkTimestampKey] = self.timestamp
        return json
    }
}
