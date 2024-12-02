import NIOHTTP1

extension HTTPHeaders:HTTP.HeaderFormat
{
    init(origin:HTTP.ServerOrigin, status _:UInt)
    {
        self = ["host": origin.authority]
    }
}
