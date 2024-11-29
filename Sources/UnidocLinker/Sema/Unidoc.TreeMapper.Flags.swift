import JSON

extension Unidoc.TreeMapper
{
    enum Flags:Int
    {
        case deprecated = 0
        case spi = 1
    }
}
extension Unidoc.TreeMapper.Flags:JSONEncodable, JSONDecodable
{
}
