import Unidoc

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
    func contains(_ scalar:Unidoc.Scalar) -> Bool
    {
        scalar.package == self.package &&
        scalar.version == self.version
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
    subscript(citizen citizen:Int32) -> Unidoc.Scalar
    {
        .init(package: self.package, version: self.version, citizen: citizen)
    }
    /// Augments and tags the passed module index to form a global address.
    /// This transformation is only valid if the module is a culture within
    /// the relevant snapshot.
    subscript(culture culture:Int) -> Unidoc.Scalar
    {
        .init(package: self.package, version: self.version, culture: culture)
    }
}
extension Snapshot.Translator
{
    subscript(scalar scalar:Unidoc.Scalar) -> Int32?
    {
        self.contains(scalar) ? scalar.citizen : nil
    }
    subscript(module scalar:Unidoc.Scalar) -> Int?
    {
        self.contains(scalar) ? scalar.culture : nil
    }
}
