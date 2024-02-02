//
//  VepayBaseURLS.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 09.01.2024.
//

import WebKit.WKWebView

public final class VepayUtils {
    
    private init() { }
    
    // MARK: - H2H URL
    
    /// For URL Creation
    /// * "https://\(isTest ? "test" : "api").vepay.online/h2hapi/v1/\(endpoint)"
    /// - Parameter endpoint: Endpoint without first slash
    public static func h2hURL(endpoint: String, isTest: Bool = false) -> String {
        "https://\(isTest ? "test" : "api").vepay.online/h2hapi/v1/\(endpoint)"
    }
    
    
    // MARK: - MFO URL
    /// * "https://\(isTest ? "test" : "api").vepay.online/mfo/\(endpoint)"
    public static func mfoURL(endpoint: String, isTest: Bool = false) -> String {
        "https://\(isTest ? "test" : "api").vepay.online/mfo/\(endpoint)"
    }
    
    
    // MARK: - User Agent
    /// # Example: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
    public static func userAgent() -> String {
        WKWebView().value(forKey: "userAgent") as! String
    }
    
    
    // MARK: - Language
    
    /// # Example ru-RU
    public static func activeLanguage() -> String {
        Locale.current.identifier
    }
    
    /// # Example: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7
    public static func acceptLanguage() -> String {
        var acceptLanguage: String = ""
        var preferredLanguages = Locale.preferredLanguages.prefix(10)
        acceptLanguage = preferredLanguages.removeFirst()
        for language in preferredLanguages.enumerated() {
            acceptLanguage += ", \(language.element);q=0.\(9 - language.offset)"
        }
        return acceptLanguage
    }

}


// MARK: - IP

extension VepayUtils {
    
    /// First finded ipv4 (priopritization order: [wifi, cellular, wired2, wired3, wired4])
    public static func ip(specificIPVersion: IPVersion? = .ip4) -> String? {
        var address: String? = nil
        for network in Network.allCases {
            if let _address = ip(network: network, checkFor: specificIPVersion) {
                address = _address
                break
            }
        }

        return address
    }

    /// First finded ip address
    /// - Parameters:
    ///   - network: wifi = "en0"  || cellular = "pdp_ip0"
    /// - Returns: First founded ip that satisfying all parameters
    public static func ip(network: Network, checkFor ipVersion: IPVersion? = .ip4) -> String? {

        // Static propertys
        let addressValidator: (String) -> (Bool)
        switch ipVersion {
        case .ip4:
            addressValidator = {
                return Int($0.replacingOccurrences(of: "[.:-]", with: "", options: .regularExpression)) != nil
            }
        case .ip6:
            addressValidator = { $0.contains("::") }
        case .none:
            addressValidator = { _ in true }
        }
        
        var address: String? = nil
        let addresses = allIPs(for: network.rawValue)
        if !addresses.isEmpty {
            address = addresses.first(where: addressValidator)
        }

        return address
    }

    /// All ip addresses for specific name
    /// # Example: wifi = "en0"
    public static func allIPs(for networkName: String) -> [String] {
        // Variable propertys
        var addresses: [String] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return addresses }
                
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    guard let ifa_name = interface.ifa_name else { return addresses }
                    let name: String = String(cString: ifa_name)
                    if name == networkName {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        
                        addresses.append(String(cString: hostname))
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return addresses
    }

    public enum Network: String, CaseIterable {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        case wired2 = "en2"
        case wired3 = "en3"
        case wired4 = "en4"
    }

    public enum IPVersion {
        case ip4
        case ip6
    }

    
}
