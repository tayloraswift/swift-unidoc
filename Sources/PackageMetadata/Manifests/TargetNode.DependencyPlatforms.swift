import JSON
import PackageGraphs
import SymbolGraphs

extension TargetNode
{
    /// A helper type for decoding an array of dependencies.
    struct DependencyPlatforms
    {
        let names:[SymbolGraphMetadata.Platform]

        private
        init(names:[SymbolGraphMetadata.Platform])
        {
            self.names = names
        }
    }
}
extension TargetNode.DependencyPlatforms:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case names = "platformNames"
    }
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(names: try json[.names].decode())
    }
}
