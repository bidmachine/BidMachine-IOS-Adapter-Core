@_implementationOnly import Foundation

struct BidMachineFeaturesModel: Decodable {
    
    enum CreativeLoadingMethod: String, Decodable {
        
        case full = "FullLoad"
        
        case stream = "Stream"
        
        case patitial = "PartialLoad"
        
    }
    
    let skipoffset: Double?
    
    let storeURL: String?
    
    let useNativeClose: Bool?
    
    let adMarkupLoadingTimeout: Double?

    let creativeLoadingMethod: CreativeLoadingMethod?
    
    let placeholderTimeout: Double?
}
