import UnidocAutomation
import UnidocQueries
import UnidocRecords

extension UnidocAPI.PackageStatus.Edition
{
    init?(from output:Unidex.EditionsQuery.Facet)
    {
        self.init(coordinate: output.edition.version,
            graphs: output.graphs?.count ?? 0,
            tag: output.edition.name)
    }
}
