@_implementationOnly import Foundation

struct BidMachineFeaturesModel: Decodable {
    
    let skipoffset: Double?
    
    let storeURL: String?
    
    let useNativeClose: Bool?
    
    let adMarkupLoadingTimeout: Double?

    let creativeLoadingMethod: String?
    
    let placeholderTimeout: Double?
}
