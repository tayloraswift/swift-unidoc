import MarkdownABI
import UnidocRecords

extension Unidoc {
    public struct Cone {
        private let prose: Prose
        let halo: Halo

        private init(prose: Prose, halo: Halo) {
            self.prose = prose
            self.halo = halo
        }
    }
}
extension Unidoc.Cone {
    init(
        _ context: Unidoc.InternalPageContext,
        groups: borrowing [Unidoc.AnyGroup],
        apex: __shared some Unidoc.PrincipalVertex
    ) throws {
        let prose: Unidoc.Prose = .init(apex: apex)

        var curated: Set<Unidoc.Scalar> = [context.id]
        if  let markdown: Markdown.Bytecode = apex.details?.markdown {
            //  We expect that the overview should not (normally) contain cards. So we only
            //  bother recording cards that exist in the details.
            for case .load(let reference)? in markdown {
                let reference: Markdown.ProseReference = .init(reference)
                if !reference.card {
                    continue
                }

                let index: Int = reference.index

                if  prose.outlines.indices.contains(index),
                    case .path(_, let path) = prose.outlines[index],
                    case let last? = path.last {
                    curated.insert(last)
                }
            }
        }

        let halo: Halo

        if  let apex: Unidoc.DeclVertex = apex as? Unidoc.DeclVertex {
            halo = try .init(
                context,
                curated: /* consume */ curated,
                groups: groups,
                apex: apex
            )
        } else {
            halo = try .init(
                context,
                curated: /* consume */ curated,
                groups: groups,
                decl: apex.decl,
                bias: apex.bias
            )
        }

        self.init(prose: prose, halo: halo)
    }
}
extension Unidoc.Cone {
    var overviewText: Unidoc.InertSection<Unidoc.IdentifiableVertices>? {
        self.prose.overviewText(with: self.context.vertices)
    }

    var overview: Unidoc.ProseSection? { self.prose.overview(with: self.context) }
    var details: Unidoc.ProseSection? { self.prose.details(with: self.context) }

    var context: Unidoc.InternalPageContext { self.halo.context }
}
