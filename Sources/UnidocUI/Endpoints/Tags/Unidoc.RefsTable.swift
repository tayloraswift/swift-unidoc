import HTML
import Symbols

extension Unidoc
{
    struct RefsTable
    {
        private
        let package:Symbol.Package
        private
        let rows:[VersionState]
        let view:Permissions
        let type:RefsTableType

        init(package:Symbol.Package,
            rows:[VersionState],
            view:Permissions,
            type:RefsTableType = .tags)
        {
            self.package = package
            self.rows = rows
            self.view = view
            self.type = type
        }
    }
}
extension Unidoc.RefsTable:HTML.OutputStreamable
{
    static
    func += (table:inout HTML.ContentEncoder, self:Self)
    {
        table[.thead]
        {
            $0[.tr]
            {
                $0[.th] = switch self.type
                {
                case .branches: "Branch"
                case .tags:     "Tag"
                }

                $0[.th] = "Commit"
                $0[.th] = "Docs"
                $0[.th] = "Symbol Graph"
            }
        }

        table[.tbody]
        {
            var modern:(prerelease:Bool, release:Bool) = (true, true)
            for row:Unidoc.VersionState in self.rows
            {
                let row:Row = .init(package: self.package, version: row, view: self.view)

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
