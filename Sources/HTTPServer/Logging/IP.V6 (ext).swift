import CNIOLinux
import IP
import NIOCore

extension IP.V6
{
    @inlinable public
    init?(_ address:SocketAddress)
    {
        switch address
        {
        case .v4(let ip):
            let tag:UInt32 = 0x0000_ffff
            self.init(storage: (0, 0, tag.bigEndian, ip.address.sin_addr.s_addr))

        case .v6(let ip):
            self.init(storage: ip.address.sin6_addr.__in6_u.__u6_addr32)

        case .unixDomainSocket:
            return nil
        }
    }
}
