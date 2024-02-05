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
        var type:ModuleType
        public
        var dependencies:ModuleDependencies
        /// The language of the module. This doesn’t necessarily match the languages of all the
        /// individual symbols in the module.
        ///
        /// New in 0.8.8; absent in 0.8.7 or earlier. We didn’t record this consistently until
        /// 0.8.13.
        ///
        /// This field is nil if the symbol graph was not generated from a swift package.
        public
        var language:Phylum.Language?
        /// The path to the module’s source directory, relative to the
        /// package root. If nil, the path is just [`"Sources/\(self.name)"`]().
        public
        var location:String?

        @inlinable public
        init(name:String,
            type:ModuleType = .regular,
            dependencies:ModuleDependencies = .init(),
            language:Phylum.Language? = nil,
            location:String? = nil)
        {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.language = language
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
        case language = "G"
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
        bson[.language] = self.language
        bson[.location] = self.location
    }
}
extension SymbolGraph.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            name: try bson[.name].decode(),
            type: try bson[.type].decode(),
            dependencies: .init(
                products: try bson[.dependencies_products]?.decode() ?? [],
                modules: try bson[.dependencies_modules]?.decode() ?? []),
            language: try bson[.language]?.decode(),
            location: try bson[.location]?.decode())
    }
}
