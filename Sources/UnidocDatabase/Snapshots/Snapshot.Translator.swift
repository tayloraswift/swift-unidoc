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
    func contains(_ address:Scalar96) -> Bool
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
    /// a declaration, a file, or a standalone article.
    subscript(citizen citizen:Int32) -> Scalar96
    {
        .init(package: self.package, version: self.version, citizen: citizen)
    }
    /// Augments and tags the passed module index to form a global address.
    /// This transformation is only valid if the module is a culture within
    /// the relevant snapshot.
    subscript(culture culture:Int) -> Scalar96
    {
        .init(package: self.package, version: self.version, culture: culture)
    }
}
extension Snapshot.Translator
{
    subscript(scalar scalar:Scalar96) -> Int32?
    {
        self.contains(scalar) ? scalar.citizen : nil
    }
    subscript(module scalar:Scalar96) -> Int?
    {
        self.contains(scalar) ? scalar.culture : nil
    }
}
