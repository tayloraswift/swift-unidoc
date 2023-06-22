import SymbolGraphs

extension Snapshot
{
    struct Translator
    {
        private
        let package:Int32
        private
        let version:Int32

        init(package:Int32, version:Int32)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Snapshot.Translator
{
    func contains(_ address:GlobalAddress) -> Bool
    {
        address.package == self.package &&
        address.version == self.version
    }
}
//  These APIs don’t check for integer overflow; we should enforce
//  population limits during an earlier validation stage.
extension Snapshot.Translator
{
    /// Augments the passed scalar address with snapshot indices to form a
    /// global address. This transformation is only valid if the scalar is
    /// a citizen of the relevant snapshot. The scalar address may refer to
    /// either a declaration or a standalone article.
    subscript(address address:Int32) -> GlobalAddress
    {
        .init(package: self.package, version: self.version, address: address)
    }
    /// Augments and tags the passed module index to form a global address.
    /// This transformation is only valid if the module is a culture within
    /// the relevant snapshot.
    subscript(culture culture:Int) -> GlobalAddress
    {
        .init(package: self.package, version: self.version, culture: culture)
    }
}
