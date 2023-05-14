import BSONDecoding
import BSONEncoding
import PackageGraphs

extension SymbolGraph
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        /// Information about the target associated with this module.
        public
        let target:TargetNode

        /// The addresses of the top-level declarations in this module.
        ///
        /// Although a module can gain additional nested declarations
        /// through extensions, a module’s top-level namespace is intrinsic
        /// because modules themselves cannot be extended.
        public
        var members:[ScalarAddress]
        /// This module’s binary markdown documentation, if it has any.
        public
        var article:Article?

        @inlinable public
        init(target:TargetNode)
        {
            self.target = target

            self.members = []
            self.article = nil
        }
    }
}
extension SymbolGraph.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.target.id
    }
}
extension SymbolGraph.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case target_name = "N"
        case target_type = "T"
        case target_dependencies_products = "P"
        case target_dependencies_modules = "D"
        case target_location = "L"
        case members = "M"
        case article = "A"
    }
}
extension SymbolGraph.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.target_name] = self.target.name
        bson[.target_type] = self.target.type
        bson[.target_dependencies_products] =
            self.target.dependencies.products.isEmpty ? nil :
            self.target.dependencies.products
        bson[.target_dependencies_modules] =
            self.target.dependencies.modules.isEmpty ? nil :
            self.target.dependencies.modules
        bson[.target_location] = self.target.location
    }
}
extension SymbolGraph.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(target: .init(
            name: try bson[.target_name].decode(),
            type: try bson[.target_type].decode(),
            dependencies: .init(
                products: try bson[.target_dependencies_products]?.decode() ?? [],
                modules: try bson[.target_dependencies_modules]?.decode() ?? []),
            location: try bson[.target_location]?.decode()))

        self.members = try bson[.members]?.decode() ?? []
        self.article = try bson[.article]?.decode()
    }
}
