import HTML
import Symbols
import URI
import UnixTime

extension Unidoc {
    struct CompleteBuildsTable {
        let package: Symbol.Package
        let rows: [CompleteBuild]

        let view: Permissions

        init(package: Symbol.Package, rows: [CompleteBuild], view: Permissions) {
            self.package = package
            self.rows = rows
            self.view = view
        }
    }
}
extension Unidoc.CompleteBuildsTable: Unidoc.IterableTable {
    func more(page index: Int) -> URI {
        Unidoc.CompleteBuildsEndpoint[self.package, page: index]
    }
}
extension Unidoc.CompleteBuildsTable: HTML.OutputStreamable {
    static func |= (table: inout HTML.AttributeEncoder, self: Self) {
        table[data: "type"] = "complete-builds"
    }

    static func += (table: inout HTML.ContentEncoder, self: Self) {
        table[.thead] {
            $0[.tr] {
                $0[.th] = "Run time"
                $0[.th] = "Ref"
                $0[.th] = "Status"
            }
        }

        table[.tbody] {
            for row: Unidoc.CompleteBuild in self.rows {
                $0[.tr] {
                    $0[.td] {
                        let duration: DurationFormat = .init(row.finished - row.launched)

                        $0[.span] {
                            $0.class = row.failure == nil ? "success" : "failure"
                        } = duration.short
                    }

                    $0[.td] = row.name.ref
                    $0[.td, { $0.class = "status"}] {
                        switch row.failure {
                        case nil:
                            $0[.div] = "OK"

                        case .killed?:
                            $0[.div] = "Killed"

                        case .noValidVersion?:
                            $0[.div] = "No Valid Version"

                        case .failedToCloneRepository?:
                            $0[.div] = "Failed to Clone Repo"

                        case .failedToReadManifest?:
                            $0[.div] = "Failed to Read Root Manifest"

                        case .failedToReadManifestForDependency?:
                            $0[.div] = "Failed to Read Dependency Manifest"

                        case .failedToResolveDependencies?:
                            $0[.div] = "Failed to Resolve Dependencies"

                        case .failedToBuild?:
                            $0[.div] = "Failed to Build Package"

                        case .failedToExtractSymbolGraph?:
                            $0[.div] = "Failed to Extract Symbol Graph"

                        case .failedToLoadSymbolGraph?:
                            $0[.div] = "Failed to Load Symbol Graph"

                        case .failedToLinkSymbolGraph?:
                            $0[.div] = "Failed to Link Symbol Graph"

                        case .failedForUnknownReason?:
                            $0[.div] = "Failed for Unknown Reason"
                        }

                        //  You need to be logged in to view build logs.
                        guard self.view.authenticated else {
                            return
                        }

                        $0[.div, { $0.class = "menu" }] {
                            $0[.button] = "•••"
                            $0[.ul] {
                                if  row.logs.isEmpty {
                                    $0[.li] = "No logs available"
                                }
                                if  row.logsAreSecret, !self.view.editor {
                                    $0[.li] = """
                                    You are not authorized to view logs from this run.
                                    """
                                }

                                for log: Unidoc.BuildLogType in row.logs {
                                    $0[.li] {
                                        //  We never persist logs anywhere except in S3, where
                                        //  they are served through CloudFront. Therefore, we
                                        //  can safely hardcode the URL here.
                                        let path: Unidoc.BuildLogPath = .init(
                                            id: row.id,
                                            type: log
                                        )

                                        $0[.a] {
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
