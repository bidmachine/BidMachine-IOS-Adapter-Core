@_implementationOnly import Foundation

struct BidMachineIABAsset: Decodable {
    
    let style: String
    
    let fontStyle: UInt32?
    
    let width: Double?
    
    let height: Double?
    
    let margin: String?
    
    let visible: Bool?
    
    let opacity: Float?
    
    let outlined: Bool?
    
    let padding: String?
    
    let content: String?
    
    let x: String?
    
    let y: String?
    
    let hideafter: Double?
    
    let fill: String?
    
    let shadow: String?
    
    let stroke: String?
    
    let strokeWidth: Float?
    
}

struct BidMachineIABModel: Decodable {
    
    let r1Delay: Double?
    
    let r1: Bool?
    
    let r2: Bool?
    
    let progressDuration: Double?
    
    let skipoffset: Double?
    
    let storeURL: String?
    
    let useNativeClose: Bool?

    let ignoresSafeAreaLayoutGuide: Bool?

    let progress: BidMachineIABAsset?

    let countdown: BidMachineIABAsset?

    let closeButton: BidMachineIABAsset?
    
}
