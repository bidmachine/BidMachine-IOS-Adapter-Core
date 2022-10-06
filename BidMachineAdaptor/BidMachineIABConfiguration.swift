@_implementationOnly import Foundation

@_implementationOnly import BidMachine
@_implementationOnly import StackVASTKit
@_implementationOnly import StackMRAIDKit
@_implementationOnly import BidMachineApiCore
@_implementationOnly import StackProductPresentation

struct BidMachineIABConfiguration: Decodable {
    
    private enum Keys: String, CodingKey {
        
        case adm
        
        case kBDMCreativeAdm
        
        case assetInfo
        
        case storeInfo
        
        case featureInfo
        
    }
    
    let adm: String
    
    let assetInfo: BidMachineIABModel?
    
    let storeInfo: BidMachineStoreModel?
    
    let featureInfo: BidMachineFeaturesModel?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        if let adm = try? container.decode(String.self, forKey: .kBDMCreativeAdm) {
            self.adm = adm
        } else {
            self.adm = try container.decode(String.self, forKey: .adm)
        }
        
        self.assetInfo = try? container.decodeIfPresent(BidMachineIABModel.self, forKey: .assetInfo)
        self.storeInfo = try? container.decodeIfPresent(BidMachineStoreModel.self, forKey: .storeInfo)
        self.featureInfo = try? container.decodeIfPresent(BidMachineFeaturesModel.self, forKey: .featureInfo)
    }
}

extension BidMachineIABConfiguration {
    
    var mraidConfiguration: STKMRAIDWrapperConfiguration {
        let config =  STKMRAIDWrapperConfiguration()
        
        config.cacheType = self.loadingMethod
        config.presentationConfiguration = self.mraidPresentationConfiguration
        config.webConfiguration = self.mraidWebConfiguration
        config.serviceConfiguration = self.mraidServiceConfiguration
        
        return config
    }
    
    func vastConfiguration(_ placement: Placement) -> STKVASTControllerConfiguration {
        STKVASTControllerConfiguration { _ = $0
            .appendAutoclose(false)
            .appendMaxDuration(180)
            .appendRewarded(placement.isRewarded)
            .appendCacheType(self.loadingMethod)
            .appendPlaceholderTimeout(self.featureInfo?.placeholderTimeout ?? 0)
            .appendVideoCloseTime(self.featureInfo?.skipoffset ?? 0)
            .appendForceCloseTime(self.featureInfo?.useNativeClose ?? false)
            .appendPartnerName(BidMachineSdk.partnerName)
            .appendPartnerVersion(BidMachineSdk.partnerVersion)
            .appendMeasuring(true)
            .appendProductParameters(self.storeParams)
        }
    }
    
    var storeParams: [String : Any] { self.storeInfo.flatMap { $0.iabJson } ?? [:] }
    
}

private extension BidMachineIABConfiguration {
    
    var mraidPresentationConfiguration: STKMRAIDPresentationConfiguration {
        let config = STKMRAIDPresentationConfiguration()
        
        if let features = self.featureInfo {
            config.closeTime = features.placeholderTimeout ?? (features.skipoffset ?? 0)
            config.useNativeClose = features.useNativeClose ?? true
            config.productLink = features.storeURL
        }
        
        guard let iab = self.assetInfo else {
            return config
        }
        
        config.r1 = iab.r1 ?? false
        config.r2 = iab.r2 ?? false
        config.r1Delay = iab.r1Delay ?? 0
        config.duration = iab.progressDuration ?? 0
        config.ignoresSafeAreaLayout = iab.ignoresSafeAreaLayoutGuide ?? false
        
        
        if let countdown = iab.countdown {
            config.countdownAsset = countdown.configuration
        }
        
        if let closableAsset = iab.closeButton {
            config.closableAsset = closableAsset.configuration
        }
        
        if let progressAsset = iab.progress {
            config.progressAsset = progressAsset.configuration
        }
        
        config.productParameters = self.storeParams
        
        return config
    }
    
    var mraidWebConfiguration: STKMRAIDWebConfiguration {
        let config = STKMRAIDWebConfiguration()
        
        config.appendTimeout(self.featureInfo?.adMarkupLoadingTimeout ?? 0)
        return config
    }
    
    var mraidServiceConfiguration: STKMRAIDServiceConfiguration {
        let config = STKMRAIDServiceConfiguration()
        
        config.registerServices([kMRAIDSupportsInlineVideo, kMRAIDSupportsLogging, kMRAIDMeasure])
        config.partnerName = BidMachineSdk.partnerName
        config.partnerVersion = BidMachineSdk.partnerVersion
        return config
    }
    
    var loadingMethod: CacheType {
        guard let method = self.featureInfo?.creativeLoadingMethod else {
            return .fullLoad
        }
        
        switch method {
        case .full: return .fullLoad
        case .stream: return .stream
        case .patitial: return .partialLoad
        }
    }
}

private extension BidMachineIABAsset {
    
    var configuration: STKIABAsset {
        let asset = STKIABAsset()
        asset.style = self.style
        asset.visible = self.visible ?? false
        asset.strokeColor = UIColor.stk_fromHex(self.stroke) ?? .white
        asset.fillColor = UIColor.stk_fromHex(self.fill) ?? .white
        asset.shadowColor = UIColor.stk_fromHex(self.shadow) ?? .clear
        asset.hideAfter = self.hideafter ?? 0
        asset.opacity = CGFloat(self.opacity ?? 0)
        asset.outlined = self.outlined ?? false
        asset.strokeWidth = CGFloat(self.strokeWidth ?? 0)
        asset.size = CGSize(width: self.width ?? 0, height: self.height ?? 0)
        asset.horizontalPostion = STKIABAssetHorizontalPositionFromSTKIABString(self.x, .left)
        asset.verticalPostion = STKIABAssetVerticalPositionFromSTKIABString(self.y, .top)
        asset.insets = UIEdgeInsetsFromSTKIABString(self.padding, STKIABDefaultInsets())
        asset.margin = UIEdgeInsetsFromSTKIABString(self.margin, STKIABDefaultInsets())
        asset.font = UIFontFromSTKIABFontStyleString("\(self.fontStyle ?? 0)")
        
        if let content = self.content, content != "" {
            asset.content = content
        }
        
        return asset
    }
    
}
