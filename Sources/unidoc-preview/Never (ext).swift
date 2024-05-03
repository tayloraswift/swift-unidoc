import HTTPServer
import IP

extension Never:HTTP.ServerPolicy
{
    public
    func load() -> IP.Policylist? { nil }
}
