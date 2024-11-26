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
        let autonomousSystem:IP.AS.Metadata?
        public
        let claimant:IP.Claimant?
        public
        let country:ISO.Country?

        public
        let unknown:Bool

        init(ip:IP.V6,
            autonomousSystem:IP.AS.Metadata? = nil,
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
    static func lookup(ip:IP.V6, in mappings:IP.Mappings?) -> Self
    {
        guard
        let mappings:IP.Mappings
        else
        {
            return .init(ip: ip, unknown: true)
        }

        let autonomousSystem:IP.AS.Metadata?
        if  let asn:IP.ASN = mappings.autonomousSystems[v6: ip]
        {
            autonomousSystem = mappings.autonomousSystemMetadata[asn]
        }
        else
        {
            autonomousSystem = nil
        }

        return .init(ip: ip,
            autonomousSystem: autonomousSystem,
            claimant: mappings.claimants[v6: ip],
            country: mappings.countries[v6: ip],
            unknown: false)
    }
}
