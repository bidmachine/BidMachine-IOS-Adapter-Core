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
        
        case kBDMAssetInfo
        
        case kBDMStoreInfo
        
        case skadn
        
        case kBDMAdMarkupTimeout
        
        case kBDMEmbeddedBrowser
        
    }
    
    let adm: String
    
    let iab: BidMachineIABModel?
    
    let store: BidMachineStoreModel?
    
    let adMarkupLoadingTimeout: Double?
    
    let useEmbeddedBrowser: Bool?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let storeContainter = try container.nestedContainer(keyedBy: Keys.self, forKey: .kBDMStoreInfo)
        
        if let adm = try? container.decode(String.self, forKey: .kBDMCreativeAdm) {
            self.adm = adm
        } else {
            self.adm = try container.decode(String.self, forKey: .adm)
        }
        
        self.iab = try? container.decodeIfPresent(BidMachineIABModel.self, forKey: .kBDMAssetInfo)
        self.store = try? storeContainter.decodeIfPresent(BidMachineStoreModel.self, forKey: .skadn)
        self.adMarkupLoadingTimeout = try? container.decodeIfPresent(Double.self, forKey: .kBDMAdMarkupTimeout)
        self.useEmbeddedBrowser = try? container.decodeIfPresent(Bool.self, forKey: .kBDMEmbeddedBrowser)
    }
}

extension BidMachineIABConfiguration {
    
    var mraidConfiguration: STKMRAIDPresentationConfiguration {
        let config = STKMRAIDPresentationConfiguration()
        guard let iab = self.iab else {
            return config
        }
        config.closeTime = iab.skipoffset ?? 0
        config.duration = iab.progressDuration ?? 0
        config.useNativeClose = iab.useNativeClose ?? true
        config.r1 = iab.r1 ?? false
        config.r2 = iab.r2 ?? false
        config.r1Delay = iab.r1Delay ?? 0
        config.ignoresSafeAreaLayout = iab.ignoresSafeAreaLayoutGuide ?? false
        config.productLink = iab.storeURL
        
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
    
    func vastConfiguration(_ placement: Placement) -> STKVASTControllerConfiguration {
        STKVASTControllerConfiguration { _ = $0
            .appendAutoclose(false)
            .appendMaxDuration(180)
            .appendRewarded(placement.isRewarded)
            .appendVideoCloseTime(self.iab?.skipoffset ?? 0)
            .appendForceCloseTime(self.iab?.useNativeClose ?? false)
            .appendPartnerName(BidMachineSdk.partnerName)
            .appendPartnerVersion(BidMachineSdk.partnerVersion)
            .appendMeasuring(true)
            .appendProductParameters(self.storeParams)
        }
    }
    
    var storeParams: [String : Any] {
        var storeParams = self.store.flatMap { $0.iabJson } ?? [:]
        storeParams[ProductController.useEmbeddedBrowser] = self.useEmbeddedBrowser.flatMap { $0 ? 1 : 0 }
        return storeParams
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
