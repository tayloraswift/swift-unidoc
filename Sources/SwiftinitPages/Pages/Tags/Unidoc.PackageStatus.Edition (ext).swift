import UnidocAPI
import UnidocQueries

extension Unidoc.PackageStatus.Edition
{
    init?(from output:borrowing Unidoc.VersionsQuery.Tag)
    {
        self.init(coordinate: output.edition.version,
            graphs: output.graph != nil ? 1 : 0,
            tag: output.edition.name)
    }
}
