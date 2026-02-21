import Firewalls
import IP

extension HTTP {
    public protocol ServerPolicy: AnyObject, Sendable {
        /// Loads the latest available firewall, or nil if the firewall is not yet available.
        func load() -> IP.Firewall?
    }
}
