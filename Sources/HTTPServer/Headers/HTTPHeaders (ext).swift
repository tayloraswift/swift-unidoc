import NIOHTTP1

extension HTTPHeaders:HTTPHeaderFormat
{
    init(authority:(some ServerAuthority).Type, status _:UInt)
    {
        self = ["host": authority.domain]
    }
}
