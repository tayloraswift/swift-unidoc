import IP

extension HTTP
{
    public
    typealias ServerPolicy = _HTTPServerPolicy
}

/// The name of this protocol is ``HTTP.ServerPolicy``.
public
protocol _HTTPServerPolicy:Sendable
{
    /// Loads the latest available policy list.
    func load() -> IP.Policylist?
}
