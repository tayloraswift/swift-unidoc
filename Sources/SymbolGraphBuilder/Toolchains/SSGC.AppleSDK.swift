import ArgumentParser

extension SSGC {
    @frozen public enum AppleSDK: CaseIterable, Equatable, Sendable {
        case driverKit
        case iOS
        case iPhoneSimulator
        case macOS
        case tvSimulator
        case tvOS
        case visionOS
        case visionSimulator
        case watchOS
        case watchSimulator
    }
}
extension SSGC.AppleSDK: CustomStringConvertible {
    public var description: String {
        switch self {
        case .driverKit:        "DriverKit"
        case .iOS:              "iOS"
        case .iPhoneSimulator:  "iPhoneSimulator"
        case .macOS:            "macOS"
        case .tvSimulator:      "tvSimulator"
        case .tvOS:             "tvOS"
        case .visionOS:         "visionOS"
        case .visionSimulator:  "visionSimulator"
        case .watchOS:          "watchOS"
        case .watchSimulator:   "watchSimulator"
        }
    }
}
extension SSGC.AppleSDK: LosslessStringConvertible {
    public init?(_ description: String) {
        switch description.lowercased() {
        case "driverkit":       self = .driverKit
        case "ios":             self = .iOS
        case "iphonesimulator": self = .iPhoneSimulator
        case "macos":           self = .macOS
        case "tvsimulator":     self = .tvSimulator
        case "tvos":            self = .tvOS
        case "visionos":        self = .visionOS
        case "visionsimulator": self = .visionSimulator
        case "watchos":         self = .watchOS
        case "watchsimulator":  self = .watchSimulator
        default:                return nil
        }
    }
}
extension SSGC.AppleSDK: ExpressibleByArgument {
}
extension SSGC.AppleSDK {
    private var stem: String {
        switch self {
        case .driverKit:        "DriverKit"
        case .iOS:              "iPhoneOS"
        case .iPhoneSimulator:  "iPhoneSimulator"
        case .macOS:            "MacOSX"
        case .tvSimulator:      "AppleTVSimulator"
        case .tvOS:             "AppleTVOS"
        case .visionOS:         "XROS"
        case .visionSimulator:  "XRSimulator"
        case .watchOS:          "WatchOS"
        case .watchSimulator:   "WatchSimulator"
        }
    }

    var path: String {
        """
        /Applications/Xcode.app/Contents/Developer/Platforms/\
        \(self.stem).platform/Developer/SDKs/\(self.stem).sdk
        """
    }
}
