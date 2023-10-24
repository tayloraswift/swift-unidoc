import IP
import NIOCore

extension IP.Address
{
    @inlinable public
    init?(_ address:SocketAddress)
    {
        switch address
        {
        case .v4(let ip):
            let bytes:UInt32 = .init(bigEndian: ip.address.sin_addr.s_addr)
            let value:IP.V4 = .init(
                .init((bytes >> 24) & 0xFF),
                .init((bytes >> 16) & 0xFF),
                .init((bytes >>  8) & 0xFF),
                .init( bytes        & 0xFF))

            self = .v4(value)

        case .v6(let ip):
            let words:(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16) =
                ip.address.sin6_addr.__in6_u.__u6_addr16
            let value:IP.V6 = .init(
                words.0,
                words.1,
                words.2,
                words.3,
                words.4,
                words.5,
                words.6,
                words.7)

            self = .v6(value)

        case .unixDomainSocket:
            return nil
        }
    }
}
