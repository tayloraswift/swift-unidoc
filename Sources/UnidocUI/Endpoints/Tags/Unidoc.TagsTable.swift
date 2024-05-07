import HTML
import Symbols

extension Unidoc
{
    struct TagsTable
    {
        private
        let package:Symbol.Package
        private
        let tagless:Unidoc.Versions.TopOfTree?
        private
        let tagged:[Unidoc.Versions.Tag]
        let view:Permissions
        let more:Bool

        init(
            package:Symbol.Package,
            tagless:Unidoc.Versions.TopOfTree? = nil,
            tagged:[Unidoc.Versions.Tag],
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
extension Unidoc.TagsTable:HTML.OutputStreamable
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
            if  let tagless:Unidoc.Versions.TopOfTree = self.tagless
            {
                $0[.tr] { $0.class = "tagless" } = Row.init(
                    volume: tagless.volume,
                    tagged: nil,
                    package: self.package,
                    graph: tagless.graph,
                    view: self.view)
            }

            var modern:(prerelease:Bool, release:Bool) = (true, true)
            for tagged:Unidoc.Versions.Tag in self.tagged
            {
                let row:Row = .init(
                    volume: tagged.volume,
                    tagged: .init(commit: tagged.edition.sha1,
                        series: tagged.edition.series,
                        patch: tagged.edition.patch,
                        name: tagged.edition.name),
                    package: self.package,
                    graph: tagged.graph,
                    view: self.view)

                //  Only releases and prereleases appear in ``tagged``.
                if  case .release? = tagged.edition.series
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
