import HTML
import SemanticVersions
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Site.Tags.List
{
    struct Item
    {
        let edition:Realm.Edition
        let volume:Volume.Meta?
        let graphs:Int

        init(edition:Realm.Edition, volume:Volume.Meta?, graphs:Int)
        {
            self.edition = edition
            self.volume = volume
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
            volume: facet.volume,
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
        tr[.td] { $0.class = "release" } = self.edition.release ? "yes" : "no"
        tr[.td, { $0.class = "version" }]
        {
            if  let volume:Volume.Meta = self.volume
            {
                $0[.a] { $0.href = "\(Site.Docs[volume])" } = "\(self.edition.patch)"
            }
            else
            {
                $0 += "\(self.edition.patch)"
            }
        }
        tr[.td] { $0.class = "graphs" } = self.graphs > 0 ? "\(self.graphs)" : ""
    }
}
