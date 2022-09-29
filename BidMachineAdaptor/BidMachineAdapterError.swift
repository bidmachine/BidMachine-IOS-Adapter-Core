public enum BidMachineAdapterError: LocalizedError  {
    
    case unknown(String, Error? = nil)
    case noContent(String, Error? = nil)
    case badContent(String, Error? = nil)
    case expired(String, Error? = nil)
    case timeouted(String, Error? = nil)
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let message, let error): return "Any unknown error with description: \(message)".populateWithError(error)
        case .noContent(let message, let error): return "Adapter has not content (or required content): \(message)".populateWithError(error)
        case .badContent(let message, let error): return "Adapter has bas content: \(message)".populateWithError(error)
        case .expired(let message, let error): return "Adapter is expired: \(message)".populateWithError(error)
        case .timeouted(let message, let error): return "Adapter is timeouted: \(message)".populateWithError(error)
        }
    }
}

extension BidMachineAdapterError: CustomNSError {
    
    public static var errorDomain: String {
        return "com.adx.error"
    }
    
    public var errorCode: Int {
        switch self {
        case .unknown: return 108
        case .badContent: return 101
        case .noContent: return 103
        case .expired: return 107
        case .timeouted: return 201
        }
    }
}


private extension String {
    
    func populateWithError(_ error: Error?) -> String {
        guard let error = error else {
            return self
        }
        
        return self + " with wrapped error: \(error)"
    }
}
