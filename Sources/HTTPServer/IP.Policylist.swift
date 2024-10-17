import IP

extension IP
{
    @frozen public
    struct Policylist:Sendable
    {
        public
        let v4:Map<V4, Owner>
        public
        let v6:Map<V6, Owner>

        @inlinable public
        init(v4:Map<V4, Owner> = [:], v6:Map<V6, Owner> = [:])
        {
            self.v4 = v4
            self.v6 = v6
        }
    }
}
extension IP.Policylist
{
    subscript(ip:IP.V6) -> IP.Owner
    {
        if  self.v4.isEmpty,
            self.v6.isEmpty
        {
            //  Tables are uninitialized.
            return .unknown
        }

        if  let ip:IP.V4 = ip.v4,
            let owner:IP.Owner = self.v4[ip]
        {
            return owner
        }
        else if
            let owner:IP.Owner = self.v6[ip]
        {
            return owner
        }
        else
        {
            return .known
        }
    }
}
