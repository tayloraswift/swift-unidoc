import HTML
import Symbols

extension Swiftinit
{
    struct TagsTable
    {
        private
        let package:Symbol.Package
        private
        let tagless:Unidoc.VersionsQuery.Tagless?
        private
        let tagged:[Unidoc.VersionsQuery.Tag]
        let view:Permissions
        let more:Bool

        init(
            package:Symbol.Package,
            tagless:Unidoc.VersionsQuery.Tagless? = nil,
            tagged:[Unidoc.VersionsQuery.Tag],
            view:Permissions,
            more:Bool)
        {
            self.package = package
            self.tagless = tagless
            self.tagged = tagged
            self.view = view
            self.more = more
        }
    }
}
extension Swiftinit.TagsTable:HTML.OutputStreamable
{
    static
    func += (table:inout HTML.ContentEncoder, self:Self)
    {
        table[.thead]
        {
            $0[.tr]
            {
                $0[.th] = "Tag"
                $0[.th] = "Commit"
                $0[.th] = "Docs"
                $0[.th] = "Symbol Graph"
            }
        }

        table[.tbody]
        {
            if  let tagless:Unidoc.VersionsQuery.Tagless = self.tagless
            {
                $0[.tr] { $0.class = "tagless" } = Row.init(
                    volume: tagless.volume,
                    tagged: nil,
                    package: self.package,
                    graph: tagless.graph,
                    view: self.view)
            }

            var modern:(prerelease:Bool, release:Bool) = (true, true)
            for tagged:Unidoc.VersionsQuery.Tag in self.tagged
            {
                let row:Row = .init(
                    volume: tagged.volume,
                    tagged: .init(
                        release: tagged.edition.release,
                        version: tagged.edition.patch,
                        commit: tagged.edition.sha1,
                        name: tagged.edition.name),
                    package: self.package,
                    graph: tagged.graph,
                    view: self.view)

                if  tagged.edition.release
                {
                    $0[.tr] { $0.class = modern.release ? "modern" : nil } = row

                    modern = (false, false)
                }
                else
                {
                    $0[.tr] { $0.class = modern.prerelease ? "modern" : nil } = row

                    modern.prerelease = false
                }
            }
        }
    }
}
