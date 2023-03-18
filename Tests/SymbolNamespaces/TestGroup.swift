import JSON
import SymbolNamespaces
import System
import Testing

extension TestGroup
{
    func expect(symbol path:SymbolPath, in namespace:SymbolNamespace) -> SymbolDescription?
    {
        self.expect(value: namespace.symbols.first { $0.path == path })
    }
}
extension TestGroup
{
    func load(namespace filepath:FilePath) -> SymbolNamespace?
    {
        self.do
        {
            let file:[UInt8] = try filepath.read()

            let json:JSON.Object = try .init(parsing: file)
            let namespace:SymbolNamespace = try .init(json: json)

            self.expect(namespace.metadata.version ==? .v(0, 6, 0))

            return namespace
        }
    }
    func loadSymbols<Key>(filepath:FilePath,
        groups key:(SymbolDescription) throws -> Key) rethrows -> [Key: [SymbolDescription]]
    {
        try self.load(namespace: filepath).map
        {
            try .init(grouping: $0.symbols.lazy.filter { $0.visibility >= .public }, by: key)
        } ?? [:]
    }
}
