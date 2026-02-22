import HTML
import Symbols
import URI

extension Unidoc {
    struct ConsumersTable {
        let package: Symbol.Package
        let rows: [PackageDependent]

        init(package: Symbol.Package, rows: [PackageDependent]) {
            self.package = package
            self.rows = rows
        }
    }
}
extension Unidoc.ConsumersTable: Unidoc.IterableTable {
    func more(page index: Int) -> URI {
        Unidoc.ConsumersEndpoint[self.package, page: index]
    }
}
extension Unidoc.ConsumersTable: HTML.OutputStreamable {
    static func |= (table: inout HTML.AttributeEncoder, self: Self) {
        table[data: "type"] = "consumers"
    }

    static func += (table: inout HTML.ContentEncoder, self: Self) {
        table[.thead] {
            $0[.tr] {
                $0[.th] = "Package"
                $0[.th] = "Docs"
                $0[.th] = "Dependency"
            }
        }

        table[.tbody] {
            for row: Unidoc.PackageDependent in self.rows {
                $0[.tr] {
                    $0[.td] {
                        $0[.a] {
                            $0.href = "\(Unidoc.RefsEndpoint[row.package.symbol])"
                        } = "\(row.package.symbol)"
                    }

                    $0[.td, { $0.class = "version" }] {
                        guard
                        let volume: Unidoc.VolumeMetadata = row.volume else {
                            return
                        }

                        $0[.a] {
                            $0.href = "\(Unidoc.DocsEndpoint[volume])"
                        } = volume.symbol.version
                    }

                    $0[.td] {
                        $0.class = "ref"
                        $0.title = row.packageRef.map { "\(row.edition.name) → \($0)" }
                    } = row.packageRef ?? "?"
                }
            }
        }
    }
}
