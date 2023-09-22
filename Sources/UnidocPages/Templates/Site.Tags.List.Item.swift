import HTML
import SemanticVersions
import UnidocDB
import UnidocQueries

extension Site.Tags.List
{
    struct Item
    {
        let edition:PackageEdition
        let graphs:Int

        init(edition:PackageEdition, graphs:Int)
        {
            self.edition = edition
            self.graphs = graphs
        }
    }
}
extension Site.Tags.List.Item
{
    init(facet:PackageEditionsQuery.Facet)
    {
        self.init(
            edition: facet.edition,
            graphs: facet.graphs?.count ?? 0)
    }
}
extension Site.Tags.List.Item:HyperTextOutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        let sha1:String? = self.edition.sha1?.description

        tr[.td] { $0.class = "refname" } = self.edition.name
        tr[.td] { $0.class = "commit" ; $0.title = sha1 } = sha1?.prefix(7) ?? ""
        tr[.td] { $0.class = "id" } = "\(self.edition.id.version)"
        tr[.td] { $0.class = "version" } = "\(self.edition.patch)"
        tr[.td] { $0.class = "release" } = self.edition.release ? "yes" : "no"
        tr[.td] { $0.class = "graphs" } = self.graphs > 0 ? "\(self.graphs)" : ""
    }
}
