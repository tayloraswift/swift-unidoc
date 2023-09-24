import UnidocAutomation
import UnidocQueries

extension PackageBuildStatus.Edition
{
    init?(from output:PackageEditionsQuery.Facet)
    {
        self.init(graphs: output.graphs?.count ?? 0, tag: output.edition.name)
    }
}
