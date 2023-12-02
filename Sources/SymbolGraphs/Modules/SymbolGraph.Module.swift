import BSON
import Symbols

extension SymbolGraph
{
    @frozen public
    struct Module:Equatable, Hashable, Sendable
    {
        /// The *unmangled* name of the module. (Not the module’s ``id``!)
        public
        let name:String
        /// The type of the module.
        public
        let type:ModuleType
        public
        let dependencies:ModuleDependencies
        /// The path to the module’s source directory, relative to the
        /// package root. If nil, the path is just [`"Sources/\(self.name)"`]().
        public
        let location:String?

        @inlinable public
        init(name:String,
            type:ModuleType = .regular,
            dependencies:ModuleDependencies = .init(),
            location:String? = nil)
        {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.location = location
        }
    }
}
extension SymbolGraph.Module:Identifiable
{
    /// The mangled name of the module.
    @inlinable public
    var id:Symbol.Module
    {
        .init(mangling: self.name)
    }
}
extension SymbolGraph.Module
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case name = "N"
        case type = "T"
        case dependencies_products = "P"
        case dependencies_modules = "D"
        case location = "L"
    }
}
extension SymbolGraph.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.name] = self.name
        bson[.type] = self.type
        bson[.dependencies_products] =
            self.dependencies.products.isEmpty ? nil :
            self.dependencies.products
        bson[.dependencies_modules] =
            self.dependencies.modules.isEmpty ? nil :
            self.dependencies.modules
        bson[.location] = self.location
    }
}
extension SymbolGraph.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            name: try bson[.name].decode(),
            type: try bson[.type].decode(),
            dependencies: .init(
                products: try bson[.dependencies_products]?.decode() ?? [],
                modules: try bson[.dependencies_modules]?.decode() ?? []),
            location: try bson[.location]?.decode())
    }
}
