// https://www.invasivecode.com/weblog/network-reachability-in-swift/
#if canImport(Foundation)
import Foundation
#endif

#if canImport(SystemConfiguration)
import SystemConfiguration
#endif

#if !os(watchOS) || !os(Linux)
public let kReachabilityDidChangeNotificationName = "ReachabilityDidChangeNotification"

public struct ReachabilityStatus: OptionSet {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let notReachable = ReachabilityStatus(rawValue: 0 << 1)
    public static let wifiReachable = ReachabilityStatus(rawValue: 1 << 1)
    public static let wwanReachable = ReachabilityStatus(rawValue: 2 << 1)
}

/**
 * How to use reachability
 *
 * var reachability: ReachabilityService? = ReachabilityService.networkReachabilityForLocalWiFi()
 *
 * @discardableResult
 * func configureReachability() -> Self {
 *    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: kReachabilityDidChangeNotificationName), object: nil)
 *    reachability?.start()
 *    return self
 * }
 *
 * @objc func reachabilityDidChange(_ notification: Notification?) {
 *     guard let r = reachability else { return }
 *     if r.isReachability {
 *        self.rootViewController.view.backgroundColor = UIColor(colorName: ColorName.blackPearl)
 *        self.add(children: self.rootTabBarController)
 *     } else {
 *        self.rootViewController.view.blsackgroundColor = .red
 *        self.remove(children: self.rootTabBarController)
 *     }
 * }
 */
public class ReachabilityService {
    private var networkReachability: SCNetworkReachability?
    private var notifying: Bool = false
    private var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, { SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0)) }) == true {
            return flags
        } else {
            return []
        }
    }

    public var currentReachabilityStatus: ReachabilityStatus {
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
#if os(iOS)
        if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .wwanReachable
        }
#endif
        if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .wifiReachable
        }
        if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .wifiReachable
        }
        return .notReachable
    }

    public var isReachability: Bool {
        switch currentReachabilityStatus {
        case .notReachable:
            return false
        case .wifiReachable:
            return true
#if os(iOS)
        case .wwanReachable:
            return true
#endif
        default:
            return false
        }
    }

    public init?(hostName: String) {
        networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, (hostName as NSString).utf8String!)
        if networkReachability == nil {
            return nil
        }
    }

    public init?(hostAddress: sockaddr_in) {
        var address = hostAddress

        guard let defaultRouteReachability = withUnsafePointer(to: &address, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0) })
        }) else {
            return nil
        }

        networkReachability = defaultRouteReachability
        if networkReachability == nil {
            return nil
        }
    }

    public static func networkReachabilityForInternetConnection() -> ReachabilityService? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return ReachabilityService(hostAddress: zeroAddress)
    }

    public static func networkReachabilityForLocalWiFi() -> ReachabilityService? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0 (0xA9FE0000).
        localWifiAddress.sin_addr.s_addr = 0xA9FE_0000
        return ReachabilityService(hostAddress: localWifiAddress)
    }

    @discardableResult
    public func start() -> Bool {
        guard notifying == false else {
            return false
        }

        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let reachability = networkReachability,
              SCNetworkReachabilitySetCallback(reachability, { _, _, info in
                  if let currentInfo = info {
                      let infoObject = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue()
                      if infoObject is ReachabilityService {
                          let networkReachability = infoObject as? ReachabilityService
                          NotificationCenter.default.post(
                              name: Notification.Name(rawValue: kReachabilityDidChangeNotificationName),
                              object: networkReachability,
                              userInfo: nil
                          )
                      }
                  }
              }, &context) == true
        else { return false }

        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else { return false }

        notifying = true
        return notifying
    }

    public func stop() {
        if let reachability = networkReachability, notifying == true {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode as! CFString)
            notifying = false
        }
    }

    deinit {
        stop()
        debugPrint("ReachabilityService")
    }
}
#endif
