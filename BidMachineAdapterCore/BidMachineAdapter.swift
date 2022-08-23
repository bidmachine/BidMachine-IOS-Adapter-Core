import Foundation
import BidMachine

public struct BidMachineAdapter {
    
    public static var adapterVerstionPath: String {
        var separator = BidMachineSdk.sdkVersion.components(separatedBy: ".")
        _ = separator.removeLast()
        return separator.joined(separator: ".")
        
    }
}
