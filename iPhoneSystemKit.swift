//
//  iPhoneSystemKit.swift
//  iPhoneSystemKit
//
//  Created by Devin on 2017/12/13.
//  Copyright © 2017年 Devin. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony
import SystemConfiguration

/**
 收集信息目录：
    |_ 1. app版本号
    |_ 2. 系统名称
    |_ 3. 当前系统版本号
    |_ 4. 设备的唯一标识
    |_ 5. model
    |_ 6. 设备型号
    |_ 7. 手机磁盘空间(手机总空间,手机剩余空间)
    |_ 8.系统时间
        |_ 8.1 系统运行时间
        |_ 8.2 系统启动时间
    |_ 9. 电池
        |_ 9.1 当前电池电量
        |_ 9.2 电池当前的状态
    |_ 10. 运营商
        |_ 11. 内存
        |_ 11.1 手机物理内存
        |_ 11.2 内存使用情况 (free、active、inactive、wired、compressed)
        |_ 11.3 当前任务所占用的内存
    |_ 12. 手机网络IP地址
        |_ 12.1 移动网络IP地址
        |_ 12.2 仅wifi网络IP地址
        |_ 12.3 公网IP地址
    |_ 13.CPU使用率(system, user, idle, nice)
    |_ 14.网络状态
    |_ 14.1 网络是否连接
    |_ 14.2 网络连接类型(2G、3G、4G、WIFI)
 */

fileprivate let IOS_CELLULAR = "pdp_ip0"
fileprivate let IOS_WIFI = "en0"
fileprivate let IOS_VPN = "utun0"
fileprivate let IP_ADDR_IPv4 = "ipv4"
fileprivate let IP_ADDR_IPv6 = "ipv6"
fileprivate var loadPrevious = host_cpu_load_info()

/// Defines the various states of network reachability.
///
/// - unknown:      It is unknown whether the network is reachable.
/// - notReachable: The network is not reachable.
/// - reachable:    The network is reachable.
public enum NetworkReachabilityStatus {
    case unknown
    case notReachable
    case reachable(ConnectionType)
}

/// Defines the various connection types detected by reachability flags.
///
/// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
/// - wwan:           The connection type is a WWAN connection.
public enum ConnectionType {
    case ethernetOrWiFi
    case wwan
}

@available (iOS 9.0 ,*)
open class iPhoneSystemKit : NSObject {
    
    /// app版本号
    ///
    /// - Returns: app版本号
    open static func appVerion() -> String {
        
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    /// 系统名称，如iPhone OS
    ///
    /// - Returns: 当前系统名称
    open static func systemName() -> String {
        return UIDevice.current.systemName
    }
    
    /// 当前系统版本号
    ///
    /// - Returns: 当前系统版本号
    open static func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /// 设备的唯一标识号，deviceID
    ///
    /// - Returns: 唯一识别码uuid
    open static func uuid() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    /// The model of the device，如iPhone或者iPod touch
    ///
    /// - Returns: 设备
    open static func model() -> String {
        return UIDevice.current.model
    }
    
    /// The model of the device as a localized string，类似model
    ///
    /// - Returns: localizedModel
    open static func localizedModel() -> String {
        return UIDevice.current.localizedModel
    }
    
    /// 设备型号(iPod、iPhone、iPad)
    /// 详细参考地址：https://www.theiphonewiki.com/wiki/Models
    /// - Returns: 设备型号
    open static func deviceName() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod4,1":                                 return "iPod Touch 4"
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    /// 手机磁盘空间
    ///  - 手机总空间:手机上显示的非真正的大小。链接mac的iTunes可查看实际大小
    ///  - 手机剩余空间:因为获取到设备上剩余的可用空间与显示的有差异，所以（+ - 200 Mb差异）
    ///  - 相关链接Q1:https://stackoverflow.com/questions/5712527/how-to-detect-total-available-free-disk-space-on-the-iphone-ipad-device
    ///  - 相关链接Q2:https://stackoverflow.com/questions/9270027/iphone-free-space-left-on-device-reported-incorrectly-200-mb-difference
    /// - Returns: (手机总空间,手机剩余空间)
    open static func getFreeDiskspace() -> (Double,Double) {
        var totalSpace:Double = 0.0
        var totalFreeSpace:Double = 0.0
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!)
        
        guard dictionary != nil else {
            return (totalSpace,totalFreeSpace)
        }
        
        let fileSystemSizeInBytes = dictionary![FileAttributeKey.systemSize] as! Double
        let freeFileSystemSizeInBytes = dictionary![FileAttributeKey.systemFreeSize] as! Double
        totalSpace = fileSystemSizeInBytes / pow(1024, 3)
        totalFreeSpace = (freeFileSystemSizeInBytes - (200 * pow(1024, 2))) / pow(1000, 3)
        return (totalSpace,totalFreeSpace)
    }
    
    /// 系统运行时间（运行多少秒）
    ///
    /// - Returns: TimeInterval
    open static func getSystemUptime() -> TimeInterval {
        return ProcessInfo().systemUptime
    }
    
    /// 系统启动时间
    ///
    /// - Returns: TimeInterval
    open static func getLaunchTime() -> TimeInterval {
        let nowTime = Date()
        let nowTimeInterval = nowTime.timeIntervalSince1970
        return nowTimeInterval - getSystemUptime()
    }
    
    /// 获取当前电池电量0.0~1.0
    ///
    /// - Returns: Float
    open static func getBatteryLevel() -> Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }
    
    /// 获取电池当前的状态,共有4种状态
    ///  - .charging (plugged in, less than 100% - 充电中)
    ///  - .full (plugged in, at 100% - 满电)
    ///  - .unplugged (on battery, discharging - 未充电,放电中)
    ///  - .unknown (isBatteryMonitoringEnabled is false)
    /// - Returns: UIDeviceBatteryState
    open static func getBatteryState() -> UIDeviceBatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryState
    }
    
    /// 运营商
    /// - example: "中国移动"
    /// - Returns: String
    open static func getCarrierName() -> String {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        guard carrier != nil else {
            return ""
        }
        return carrier!.carrierName ?? ""
    }
    
    // MARK: - IP
    
    /// 获取当前wifi的IP地址
    ///
    /// - Returns: String
    open static func getLocalIPAddressForCurrentWiFi() -> String? {
        var address: String?
        
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            
            let interface = ifptr.pointee
            
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == IOS_WIFI {
                    
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return address
    }
    
    /// 获取当前手机网络ip地址
    /// - example:
    ///         [ "awdl0/ipv6": "fe80::d0fa:xxxx:xxxx:xxxx%awdl0",
    ///           "en0/ipv6": "fe80::c95:xxxx:xxxx:xxxx%en0",
    ///           "pdp_ip0/ipv4": "10.199.xxx.xxx", // 移动网络ip地址
    ///           "en0/ipv4": "172.20.xxx.xxx", // Wi-Fi ip地址
    ///           "utun0/ipv6": "fe80::6b12:xxxx:xxxx:xxxx%utun0"]
    /// - Returns: [String:String]
    open static func getIFAddresses() -> [String:String] {
        var addresses = [String:String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [:] }
        guard let firstAddr = ifaddr else { return [:] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Convert sockaddr to sockaddr_in
            var addr_in:sockaddr_in = withUnsafePointer(to: &addr, {
                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                    $0.pointee
                }
            })
            
            // Create UnsafeMutablePointer<CChar>
            let addrBuf = UnsafeMutablePointer<CChar>.allocate(capacity: Int(max(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)))
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        let name = String(cString: ptr.pointee.ifa_name)
                        var type = ""
                        
                        if addr_in.sin_family == UInt8(AF_INET) {
                            if (inet_ntop(AF_INET, &addr_in.sin_addr, addrBuf, socklen_t(INET_ADDRSTRLEN)) != nil) {
                                type = IP_ADDR_IPv4
                            }
                        }else {
                            // Convert sockaddr to sockaddr_in6
                            var addr6:sockaddr_in6 = withUnsafePointer(to: &addr, {
                                $0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {
                                    $0.pointee
                                }
                            })
                            
                            if (inet_ntop(AF_INET, &addr6.sin6_addr, addrBuf, socklen_t(INET6_ADDRSTRLEN)) != nil) {
                                type = IP_ADDR_IPv6
                            }
                        }
                        
                        if !type.isEmpty {
                            let key = "\(name)/\(type)"
                            addresses[key] = address
                        }
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    
    /// 获取当前手机网络ip地址
    ///
    /// - Returns: (移动网络ip地址, Wi-Fi ip地址)
    open static func getIPAddress() -> (cellularIp:String,wifiIp:String){
        let searchArray = getIFAddresses()
        var wifi = ""
        var cellular = ""
        for (_,value) in searchArray.enumerated() {
            if isValidatIP(value.value) && value.key == IOS_CELLULAR + "/" + IP_ADDR_IPv4 {
                cellular = value.value
                continue
            }
            
            if isValidatIP(value.value) && value.key == IOS_WIFI + "/" + IP_ADDR_IPv4 {
                wifi = value.value
                continue
            }
        }
        return (cellular,wifi)
    }
    
    /// 获取公网ip
    ///可以通过接口请求查询ip所在的省份, 格式：http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=192.108.xxx.xxx
    /// http://ysj5125094.iteye.com/blog/2227874
    /// - Parameter url: input: www.baidu.com
    /// - Returns: String?
    open static func getIPAddressFromDNSQuery(url: String) -> String? {
        let host = CFHostCreateWithName(nil, url as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean =  false
        if let address = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?, let theAddress = address.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                return numAddress
            }
            return nil
        }
        return nil
    }
    
    /// 筛选出IP地址格式
    ///
    /// - Parameter ipAddress: String
    /// - Returns: Bool
    fileprivate static func isValidatIP(_ ipAddress:String) -> Bool {
        
        if ipAddress.isEmpty {
            return false
        }
        
        let urlRegEx = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
        let regex = try? NSRegularExpression(pattern: urlRegEx, options: .caseInsensitive)
        
        if regex != nil {
            let firstMatch = regex?.firstMatch(in: ipAddress, options: .reportProgress, range: NSRange(location: 0, length: ipAddress.count))
            if firstMatch != nil {
                return true
            }
        }
        return false
    }
    
    // MARK: - CPU
    
    /// 获取CPU使用率 (单位: 100%)
    /// 参考: https://github.com/beltex/SystemKit
    /// - Returns: (system, user, idle, nice)
    open static func usageCPU() -> (system:Double, user:Double, idle:Double, nice:Double) {
        
        let load = hostCPULoadInfo()
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        // the current and last call. Thus, first call will always be inaccurate.
        loadPrevious = load
        
        return (sys, user, idle, nice)
    }
    
    /// CPU负载信息
    ///
    /// - Returns: host_cpu_load_info
    fileprivate static func hostCPULoadInfo() -> host_cpu_load_info {
        var size:mach_msg_type_number_t =
            UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO,
                            $0,
                            &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate(capacity: 1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                    + "\(result)")
            }
        #endif
        
        return data
    }
    
    // MARK: - Memory
    
    /// 获取总内存大小（单位：GB）
    ///
    /// - Returns: Double
    open static func getTotalMemorySize() -> Double {
        return Double(ProcessInfo().physicalMemory) / pow(1024, 3)
    }
    
    /// 虚拟内存统计信息
    ///
    /// - Returns: vm_statistics64
    fileprivate static func VMStatistics64() -> vm_statistics64 {
        let HOST_VM_INFO64_COUNT:mach_msg_type_number_t =
            UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var size = HOST_VM_INFO64_COUNT
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(mach_host_self(),
                              HOST_VM_INFO64,
                              $0,
                              &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate(capacity: 1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                    + "\(result)")
            }
        #endif
        
        return data
    }
    
    /// 获取当前设备内存使用情况（单位：GB）
    /// 参考: https://github.com/beltex/SystemKit
    /// - Returns: (free, active, inactive, wired, compressed)
    open static func memoryUsage() -> (free:Double, active:Double, inactive:Double, wired:Double, compressed:Double) {
        let stats = VMStatistics64()
        let PAGE_SIZE = vm_kernel_page_size
        let free = Double(stats.free_count) * Double(PAGE_SIZE) / pow(1024, 3)
        let active = Double(stats.active_count) * Double(PAGE_SIZE) / pow(1024, 3)
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE) / pow(1024, 3)
        let wired = Double(stats.wire_count) * Double(PAGE_SIZE) / pow(1024, 3)
        
        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE) / pow(1024, 3)
        
        return (free, active, inactive, wired, compressed)
    }
    
    /// 获取当前任务所占用的内存（单位：GB）
    /// 参考: https://stackoverflow.com/questions/40991912/how-to-get-memory-usage-of-my-application-and-system-in-swift-by-programatically
    /// - Returns: Double
    open static func appUsedMemory() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        #if DEBUG
            if kerr != KERN_SUCCESS {
                print("Error with task_info(): " +
                    (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            }
        #endif
        return Double(taskInfo.resident_size) / pow(1024, 3)
    }
    
    /// 以 MB 或 GB 字符串方式显示
    ///
    /// - Parameter value: Double
    /// - Returns: String
    open static func memoryUnit(_ value: Double) -> String {
        if value < 1.0 {
            return String(format:"%.2f",value * 1000.0) + "MB"
        } else {
            return String(format:"%.2f", value) + "GB"
        }
    }
    
    // MARK: - Network
    
    /// 检查网络连接,判断网络类型(ethernetOrWiFi / wwan)
    /// 参考: https://github.com/Alamofire/Alamofire
    /// - Returns: (check connected, Network Reachability Status)
    open static func connectedToNetwork() -> (connected:Bool,connectionType:NetworkReachabilityStatus) {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return (false,.unknown)
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return (false,.unknown)
        }
        
        let conType = flags.contains(.isWWAN) ?  ConnectionType.wwan : ConnectionType.ethernetOrWiFi
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        guard isReachable && (!needsConnection || canConnectWithoutUserInteraction) else {
            return (false,.notReachable)
        }
        
        return (true,.reachable(conType))
    }
    
    /// 网络状态(2G、3G、4G、WIFI)
    ///
    /// - Returns: String
    open static func getNetWorkTypee() -> String {
        let result = "未知网络"
        let info = CTTelephonyNetworkInfo()
        let netWork = connectedToNetwork()
        
        guard netWork.connected else {
            return "未连接网络"
        }
        
        switch netWork.connectionType {
        case .reachable(.ethernetOrWiFi):
            return "WIFI"
        case .reachable(.wwan):
            let currentRadioAccessTechnology = info.currentRadioAccessTechnology
            guard currentRadioAccessTechnology != nil else {
                return result
            }
            
            if currentRadioAccessTechnology! == CTRadioAccessTechnologyLTE {
                return "4G"
            }else if (currentRadioAccessTechnology! == CTRadioAccessTechnologyEdge) || (currentRadioAccessTechnology! == CTRadioAccessTechnologyGPRS) {
                return "2G"
            }else {
                return "3G"
            }
            
        default:
            return result
        }
    }
}
