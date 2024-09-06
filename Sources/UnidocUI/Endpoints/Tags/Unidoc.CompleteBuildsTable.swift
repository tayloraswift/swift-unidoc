import HTML
import Symbols
import URI
import UnixTime

extension Unidoc
{
    struct CompleteBuildsTable
    {
        let package:Symbol.Package
        let rows:[CompleteBuild]

        let view:Permissions

        init(package:Symbol.Package, rows:[CompleteBuild], view:Permissions)
        {
            self.package = package
            self.rows = rows
            self.view = view
        }
    }
}
extension Unidoc.CompleteBuildsTable:Unidoc.IterableTable
{
    func more(page index:Int) -> URI
    {
        Unidoc.CompleteBuildsEndpoint[self.package, page: index]
    }
}
extension Unidoc.CompleteBuildsTable:HTML.OutputStreamable
{
    static
    func |= (table:inout HTML.AttributeEncoder, self:Self)
    {
        table[data: "type"] = "complete-builds"
    }

    static
    func += (table:inout HTML.ContentEncoder, self:Self)
    {
        table[.thead]
        {
            $0[.tr]
            {
                $0[.th] = "Run time"
                $0[.th] = "Status"
                $0[.th] = "Logs"
            }
        }

        table[.tbody]
        {
            for row:Unidoc.CompleteBuild in self.rows
            {
                $0[.tr]
                {
                    $0[.td]
                    {
                        let duration:DurationFormat = .init(row.finished - row.launched)

                        $0[.span]
                        {
                            $0.class = row.failure == nil ? "success" : "failure"
                        } = duration.short
                    }

                    switch row.failure
                    {
                    case nil:
                        $0[.td]

                    case .killed?:
                        $0[.td] = "Killed"

                    case .noValidVersion?:
                        $0[.td] = "No Valid Version"

                    case .failedToCloneRepository?:
                        $0[.td] = "Failed to Clone Repo"

                    case .failedToReadManifest?:
                        $0[.td] = "Failed to Read Root Manifest"

                    case .failedToReadManifestForDependency?:
                        $0[.td] = "Failed to Read Dependency Manifest"

                    case .failedToResolveDependencies?:
                        $0[.td] = "Failed to Resolve Dependencies"

                    case .failedToBuild?:
                        $0[.td] = "Failed to Build Package"

                    case .failedToExtractSymbolGraph?:
                        $0[.td] = "Failed to Extract Symbol Graph"

                    case .failedToLoadSymbolGraph?:
                        $0[.td] = "Failed to Load Symbol Graph"

                    case .failedToLinkSymbolGraph?:
                        $0[.td] = "Failed to Link Symbol Graph"

                    case .failedForUnknownReason?:
                        $0[.td] = "Failed for Unknown Reason"
                    }

                    $0[.td]
                    {
                        if  row.logs.isEmpty
                        {
                            return
                        }

                        $0[.div, { $0.class = "menu" }]
                        {
                            $0[.button] = "•••"
                            $0[.ul]
                            {
                                for log:Unidoc.BuildLogType in row.logs
                                {
                                    $0[.li]
                                    {
                                        //  We never persist logs anywhere except in S3, where
                                        //  they are served through CloudFront. Therefore, we
                                        //  can safely hardcode the URL here.
                                        let path:Unidoc.BuildLogPath = .init(id: row.id,
                                            type: log)

                                        $0[.a]
                                        {
                                            $0.target = "_blank"
                                            $0.href = "https://static.swiftinit.org\(path)"
                                            $0.rel = .external
                                        } = log.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
