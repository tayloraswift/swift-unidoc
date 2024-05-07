import HTML
import Symbols

extension Unidoc
{
    struct TagsTable
    {
        private
        let package:Symbol.Package
        private
        let _tagless:Unidoc.Versions.TopOfTree?
        private
        let versions:[Unidoc.VersionState]
        let view:Permissions
        let more:Bool

        init(
            package:Symbol.Package,
            _tagless:Unidoc.Versions.TopOfTree? = nil,
            versions:[Unidoc.VersionState],
            view:Permissions,
            more:Bool)
        {
            self.package = package
            self._tagless = _tagless
            self.versions = versions
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
            if  let _tagless:Unidoc.Versions.TopOfTree = self._tagless
            {
                $0[.tr] { $0.class = "tagless" } = Row.init(
                    package: self.package,
                    version: _tagless,
                    view: self.view)
            }

            var modern:(prerelease:Bool, release:Bool) = (true, true)
            for version:Unidoc.VersionState in self.versions
            {
                let row:Row = .init(package: self.package, version: version, view: self.view)

                $0[.tr]
                {
                    guard
                    let series:Unidoc.VersionSeries = row.series
                    else
                    {
                        return
                    }

                    switch series
                    {
                    case .prerelease:
                        $0.class = modern.prerelease ? "modern" : nil
                        modern.prerelease = false

                    case .release:
                        $0.class = modern.release ? "modern" : nil
                        modern = (false, false)
                    }
                } = row
            }
        }
    }
}
