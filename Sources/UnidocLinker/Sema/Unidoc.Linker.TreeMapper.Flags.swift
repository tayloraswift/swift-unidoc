import JSON

extension Unidoc.Linker.TreeMapper
{
    enum Flags:Int
    {
        case deprecated = 0
        case spi = 1
    }
}
extension Unidoc.Linker.TreeMapper.Flags:JSONEncodable, JSONDecodable
{
}
