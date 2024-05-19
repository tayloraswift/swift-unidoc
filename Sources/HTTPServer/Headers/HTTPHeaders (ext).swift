import NIOHTTP1

extension HTTPHeaders:HTTP.HeaderFormat
{
    init(authority:(some HTTP.ServerAuthority).Type, status _:UInt)
    {
        self = ["host": authority.domain]
    }
}
