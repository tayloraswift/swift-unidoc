import SymbolGraphs

extension DynamicObject
{
    struct Translator
    {
        let package:Int32

        private
        let version:Int32
        private
        let modules:UInt32

        private
        init(package:Int32, version:Int32, modules:UInt32)
        {
            self.package = package
            self.version = version
            self.modules = modules
        }
    }
}
extension DynamicObject.Translator
{
    init(policies _:__shared DocumentationDatabase.Policies,
        package:Int32,
        version:Int32,
        docs:__shared Documentation) throws
    {
        //  TODO: enforce population limits
        self.init(package: package, version: version, modules: .init(docs.graph.cultures.count))
    }
    init(policies:__shared DocumentationDatabase.Policies,
        object:__shared DynamicObject) throws
    {
        try self.init(policies: policies,
            package: object.package,
            version: object.version,
            docs: object.docs)
    }
}
//  These APIs don’t check for integer overflow; we should enforce
//  population limits during an earlier validation stage.
extension DynamicObject.Translator
{
    /// Shifts the passed scalar address into a global address. This
    /// transformation is only valid if the scalar is a citizen of ``package``.
    subscript(scalar address:Int32) -> GlobalAddress
    {
        .init(
            package: self.package,
            version: self.version,
            citizen: self.modules + .init(address))
    }
    /// Shifts the passed module index into a global address. This
    /// transformation is only valid if the module is a culture of ``package``.
    subscript(culture culture:Int) -> GlobalAddress
    {
        .init(
            package: self.package,
            version: self.version,
            citizen: .init(culture))
    }
    subscript(article article:Int) -> GlobalAddress
    {
        .init(
            package: self.package,
            version: self.version,
            citizen: 0x8000_0000 + .init(article))
    }
}
extension DynamicObject.Translator
{
    subscript(address:GlobalAddress) -> LocalAddress
    {
        assert(address.package == self.package)
        assert(address.version == self.version)

        if      address.citizen < self.modules
        {
            return .culture(.init(address.citizen))
        }
        else if address.citizen < 0x8000_0000
        {
            return .scalar(.init(bitPattern: address.citizen - self.modules))
        }
        else
        {
            return .article(.init(address.citizen - 0x8000_0000))
        }
    }
}
