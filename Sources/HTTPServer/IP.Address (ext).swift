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

        case let address:
            guard
            let v6:Self = .v6(address.description)
            else
            {
                return nil
            }

            self = v6
        }
    }
}
