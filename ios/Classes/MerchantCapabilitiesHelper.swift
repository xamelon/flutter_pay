import PassKit

class MerchantCapabilitiesHelper {
    static func decodeCapabilities(_ capabilities: [String]?) ->  PKMerchantCapability {
        if(capabilities == nil){
            return .capability3DS;
        }
        
        var decodeCapabilities: PKMerchantCapability = [];
        
        if(capabilities!.contains(".CAPABILITY3DS") ){
            decodeCapabilities = decodeCapabilities.union(.capability3DS)
        }
        if(capabilities!.contains(".CAPABILITYEMV")){
            decodeCapabilities = decodeCapabilities.union(.capabilityEMV)
        }
        if(capabilities!.contains(".CAPABILITYCREDIT")){
            decodeCapabilities = decodeCapabilities.union(.capabilityCredit)
        }
        if(capabilities!.contains(".CAPABILITYDEBIT")){
            decodeCapabilities = decodeCapabilities.union(.capabilityDebit)
        }
        if(!capabilities!.contains(".CAPABILITY3DS") && !capabilities!.contains(".CAPABILITYEMV")){
            decodeCapabilities = decodeCapabilities.union(.capability3DS)
        }
        
        return decodeCapabilities;
    }
}
