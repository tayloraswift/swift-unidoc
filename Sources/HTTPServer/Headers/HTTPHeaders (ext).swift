import NIOHTTP1

extension HTTPHeaders:HTTP.HeaderFormat
{
    init(origin:HTTP.Origin, status _:UInt)
    {
        self = ["host": origin.domain]
    }
}
