import LexicalPaths
import Signatures
import SourceDiagnostics
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc {
    struct LinkerTable<Group> where Group: LinkerIndexable {
        private var table: [Group.Signature: Group]

        private init(table: [Group.Signature: Group]) {
            self.table = table
        }
    }
}
extension Unidoc.LinkerTable: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral: (Group.Signature, Never)...) {
        self.init(table: [:])
    }
}
extension Unidoc.LinkerTable: Sequence {
    func makeIterator() -> Dictionary<Group.Signature, Group>.Iterator {
        self.table.makeIterator()
    }
}
extension Unidoc.LinkerTable {
    consuming func load() -> [(key: Group.Signature, value: Group)] {
        var extensions: [(key: Group.Signature, value: Group)]

        extensions = self.table.filter { !$0.value.isEmpty }
        extensions.sort { $0.1.id < $1.1.id }

        return extensions
    }
}
extension Unidoc.LinkerTable {
    private var next: Unidoc.LinkerIndex<Group> { .init(ordinal: self.table.count) }

    subscript(signature: Group.Signature) -> Group {
        _read {
            let id: Unidoc.LinkerIndex<Group> = self.next
            yield  self.table[signature, default: .init(id: id)]
        }
        _modify {
            let id: Unidoc.LinkerIndex<Group> = self.next
            yield &self.table[signature, default: .init(id: id)]
        }
    }
}

extension Unidoc.LinkerTable<Unidoc.Extension> {
    mutating func add(
        extensions: [SymbolGraph.Extension],
        extending extendee: Unidoc.Scalar,
        context: inout Unidoc.LinkerContext
    ) {
        for `extension`: SymbolGraph.Extension in extensions {
            let conditions: Unidoc.ExtensionConditions = .init(
                constraints: `extension`.conditions.map {
                    $0.map { context.current.scalars.decls[$0] }
                },
                culture: `extension`.culture
            )
            ;
            //  It’s possible for two locally-disjoint extensions to coalesce
            //  into a single global extension due to failure to link scalars.
            {
                for local: Int32 in `extension`.conformances {
                    if  let id: Unidoc.Scalar = context.current.scalars.decls[local] {
                        $0.conformances.append(id)
                    }
                }
                //  The feature might have been declared in a different package!
                //  This started happening when SSGC stopped emitting unqualified features
                //  as this was previously handled in ``linkCultures``.
                for local: Int32 in `extension`.features {
                    if  let id: Unidoc.Scalar = context.current.scalars.decls[local] {
                        $0.features.append(id)
                    }
                }
                for local: Int32 in `extension`.nested {
                    if  let id: Unidoc.Scalar = context.current.scalars.decls[local] {
                        $0.nested.append(id)
                    }
                }

                guard
                let article: SymbolGraph.Article = `extension`.article else {
                    return
                }
                guard case (nil, nil) = ($0.overview, $0.details) else {
                    context.diagnostics[nil] = DroppedPassagesError.fromExtension(
                        $0.id,
                        of: extendee
                    )
                    return
                }

                ($0.overview, $0.details) = context.link(article: article)
            } (&self[.extends(extendee, where: conditions)])
        }
    }

    func peers(in edition: Unidoc.Edition) -> [Int32: Unidoc.Group] {
        self.table.values.reduce(into: [:]) {
            for nested: Unidoc.Scalar in $1.nested {
                $0[nested.citizen] = $1.id.in(edition)
            }
        }
    }
}
