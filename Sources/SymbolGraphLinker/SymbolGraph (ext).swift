import FNV1
import InlineArray
import InlineDictionary
import MarkdownABI
import SourceDiagnostics
import SymbolGraphs
import Symbols

extension SymbolGraph {
    public static func link(
        projectRoot: Symbol.FileBase? = nil,
        definitions: [String: Void],
        plugins: consuming [any Markdown.CodeLanguageType] = [],
        modules: consuming [SymbolGraph.Module],
        indexes: consuming [SSGC.ModuleIndex],
        snippets: [any SSGC.ResourceFile],
        logger: any DiagnosticLogger
    ) throws -> Self {
        var linker: SSGC.Linker = .init(
            definitions: definitions,
            plugins: plugins,
            modules: modules
        )

        try linker.attach(snippets: snippets, indexes: indexes, projectRoot: projectRoot)
        try linker.collate()

        let graph: SymbolGraph = linker.link()

        try logger.emit(
            messages: linker.diagnostics.symbolicated(
                with: .init(
                    graph: graph,
                    base: projectRoot
                )
            )
        )

        return graph
    }
}
extension SymbolGraph {
    mutating func colorize(
        reexports: [SSGC.Route: InlineDictionary<FNV24, InlineArray<(Int32, Int)>>],
        with diagnostics: inout Diagnostics<SSGC.Symbolicator>
    ) {
        for (path, redirects):
            (SSGC.Route, InlineDictionary<FNV24, InlineArray<(Int32, Int)>>) in reexports {
            switch redirects {
            case .one((_, .one((let i, let exporter)))):
                self.cultures[exporter].reexports.unhashed.append(i)

            case .one((let hash, .some(let collisions))):
                diagnostics[nil] = SSGC.RouteCollisionError.init(
                    participants: collisions.map(\.0),
                    path: path,
                    hash: hash
                )

            case .some(let hashed):
                for (hash, redirects): (FNV24, InlineArray<(Int32, Int)>) in hashed {
                    switch redirects {
                    case .one((let i, let exporter)):
                        self.cultures[exporter].reexports.hashed.append(i)

                    case .some(let collisions):
                        diagnostics[nil] = SSGC.RouteCollisionError.init(
                            participants: collisions.map(\.0),
                            path: path,
                            hash: hash,
                            redirect: true
                        )
                    }
                }
            }
        }

        for i: Int in self.cultures.indices {
            {
                $0.reexports.unhashed.sort()
                $0.reexports.hashed.sort()
            } (&self.cultures[i])
        }
    }
    mutating func colorize(
        routes: [SSGC.Route: InlineDictionary<FNV24?, InlineArray<Int32>>],
        with diagnostics: inout Diagnostics<SSGC.Symbolicator>
    ) {
        for n: Int32 in self.decls.nodes.indices {
            let propogate: Bool = {
                guard
                var decl: SymbolGraph.Decl = $0 else {
                    return false
                }
                //  It would be nice if lib/SymbolGraphGen told us about the
                //  `@_documentation(visibility:)` attribute. But it does not.
                guard
                case "_"? = decl.path.last.first else {
                    return false
                }

                decl.route.underscored = true
                $0 = decl

                //  Declarations only propagate underscoredness if their children could not
                //  possibly be inherited by a different declaration.
                switch decl.phylum {
                case .actor:            return true    // Actors are always final.
                case .associatedtype:   return false   // Cannot have children.
                case .case:             return false   // Cannot have children.
                case .class:            return decl.kinks[is: .final]
                case .deinitializer:    return false   // Cannot have children.
                case .enum:             return true
                case .func:             return false   // Cannot have children.
                case .initializer:      return false   // Cannot have children.
                case .macro:            return false   // Cannot have children.
                case .operator:         return false   // Cannot have children.
                case .protocol:         return false   // Protocols are never final by nature.
                case .struct:           return true
                case .subscript:        return false   // Cannot have children.
                case .typealias:        return false   // Cannot have children.
                case .var:              return false   // Cannot have children.
                }

            } (&self.decls.nodes[n].decl)

            guard propogate else {
                continue
            }

            for `extension`: SymbolGraph.Extension in self.decls.nodes[n].extensions {
                for n: Int32 in `extension`.nested where self.decls.nodes.indices.contains(n) {
                    self.decls.nodes[n].decl?.route.underscored = true
                }
            }
        }

        for case (let path, .some(let members)) in routes {
            for (hash, addresses): (FNV24?, InlineArray<Int32>) in members {
                switch (hash, addresses) {
                case (_?, .one(let stacked)):
                    //  If `hash` is present, then we know the decl is a valid
                    //  declaration node index.
                    self.decls.nodes[stacked].decl?.route.hashed = true

                case (nil, .one(let participant)):
                    diagnostics[nil] = SSGC.RouteCollisionError.init(
                        participants: [participant],
                        path: path,
                        hash: nil
                    )

                case (let hash, .some(let participants)):
                    diagnostics[nil] = SSGC.RouteCollisionError.init(
                        participants: participants,
                        path: path,
                        hash: hash
                    )
                }
            }
        }
    }
}
