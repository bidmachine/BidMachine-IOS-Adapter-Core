@_implementationOnly import BidMachine

public struct BidMachineAdapter {
    
    public static var adapterVersionPath: String {
        var separator = BidMachineSdk.sdkVersion.components(separatedBy: ".")
        _ = separator.removeLast()
        return separator.joined(separator: ".")
        
    }
}
