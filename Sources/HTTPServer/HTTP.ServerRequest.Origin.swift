import Firewalls
import IP
import ISO

extension HTTP.ServerRequest
{
    @frozen public
    struct Origin:Equatable, Sendable
    {
        public
        let ip:IP.V6

        public
        let autonomousSystem:IP.AS?
        public
        let claimant:IP.Claimant?
        public
        let country:ISO.Country?

        public
        let unknown:Bool

        init(ip:IP.V6,
            autonomousSystem:IP.AS? = nil,
            claimant:IP.Claimant? = nil,
            country:ISO.Country? = nil,
            unknown:Bool)
        {
            self.ip = ip

            self.autonomousSystem = autonomousSystem
            self.claimant = claimant
            self.country = country
            self.unknown = unknown
        }
    }
}
extension HTTP.ServerRequest.Origin
{
    static func lookup(ip:IP.V6, in firewall:IP.Firewall?) -> Self
    {
        guard
        let firewall:IP.Firewall
        else
        {
            return .init(ip: ip, unknown: true)
        }

        let (system, claimant):(IP.AS?, IP.Claimant?) = firewall.lookup(v6: ip)

        return .init(ip: ip,
            autonomousSystem: system,
            claimant: claimant,
            country: firewall.country[v6: ip],
            unknown: false)
    }
}
