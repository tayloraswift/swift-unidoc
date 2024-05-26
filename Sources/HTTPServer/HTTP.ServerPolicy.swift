import IP

extension HTTP
{
    public
    protocol ServerPolicy:AnyObject, Sendable
    {
        /// Loads the latest available policy list.
        func load() -> IP.Policylist?
    }
}
