import IP

extension IP
{
    @frozen public
    struct Policylist:Sendable
    {
        @usableFromInline
        let v4:[(UInt8, [IP.V4: IP.Service])]
        @usableFromInline
        let v6:[(UInt8, [IP.V6: IP.Service])]

        @inlinable internal
        init(
            v4:[(UInt8, [IP.V4: IP.Service])],
            v6:[(UInt8, [IP.V6: IP.Service])])
        {
            self.v4 = v4
            self.v6 = v6
        }
    }
}
extension IP.Policylist
{
    @inlinable public
    init()
    {
        self.init(v4: [], v6: [])
    }

    @inlinable public
    init(
        v4:borrowing IP.BlockTable<IP.V4, IP.Service>,
        v6:borrowing IP.BlockTable<IP.V6, IP.Service>)
    {
        self.init(
            v4: v4.blocks.sorted { $0.key < $1.key },
            v6: v6.blocks.sorted { $0.key < $1.key })
    }
}
extension IP.Policylist
{
    subscript(ip:IP.V6) -> IP.Service?
    {
        if  self.v4.isEmpty,
            self.v6.isEmpty
        {
            //  Tables are uninitialized.
            return .unknown
        }

        if  let ip:IP.V4 = ip.v4
        {
            for (length, table):(UInt8, [IP.V4: IP.Service]) in self.v4
            {
                if  let service:IP.Service = table[ip / length]
                {
                    return service
                }
            }
        }
        else
        {
            for (length, table):(UInt8, [IP.V6: IP.Service]) in self.v6
            {
                if  let service:IP.Service = table[ip / length]
                {
                    return service
                }
            }
        }

        return nil
    }
}
