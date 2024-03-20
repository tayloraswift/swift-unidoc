import IP

extension HTTP
{
    public
    protocol ServerPolicy:Sendable
    {
        /// Loads the latest available policy list.
        func load() -> IP.Policylist?
    }
}
