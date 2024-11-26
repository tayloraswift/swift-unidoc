import Firewalls
import IP

extension HTTP
{
    public
    protocol ServerPolicy:AnyObject, Sendable
    {
        /// Loads the latest available mappings, or nil if the mappings are not yet available.
        func load() -> IP.Mappings?
    }
}
