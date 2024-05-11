import MarkdownABI
import UnidocRecords

extension Unidoc
{
    public
    struct Cone
    {
        private
        let writings:(overview:Markdown.Bytecode?, details:Markdown.Bytecode?)
        private
        let outlines:[Unidoc.Outline]

        let halo:Halo

        private
        init(
            writings:(overview:Markdown.Bytecode?, details:Markdown.Bytecode?),
            outlines:[Unidoc.Outline],
            halo:Halo)
        {
            self.writings = writings
            self.outlines = outlines
            self.halo = halo
        }
    }
}
extension Unidoc.Cone
{
    init(_ context:Unidoc.RelativePageContext,
        groups:borrowing [Unidoc.AnyGroup],
        apex:__shared some Unidoc.PrincipalVertex) throws
    {
        let outlines:[Unidoc.Outline] = apex.outlinesConcatenated

        var curated:Set<Unidoc.Scalar> = [context.id]
        if  let markdown:Markdown.Bytecode = apex.details?.markdown
        {
            //  We expect that the overview should not (normally) contain cards. So we only
            //  bother recording cards that exist in the details.
            for case .load(let reference)? in markdown
            {
                let reference:Markdown.ProseReference = .init(reference)
                if !reference.card
                {
                    continue
                }

                let index:Int = reference.index

                if  outlines.indices.contains(index),
                    case .path(_, let path) = outlines[index],
                    case let last? = path.last
                {
                    curated.insert(last)
                }
            }
        }

        let halo:Halo

        if  let apex:Unidoc.DeclVertex = apex as? Unidoc.DeclVertex
        {
            halo = try .init(context,
                curated: /* consume */ curated,
                groups: groups,
                apex: apex)
        }
        else
        {
            halo = try .init(context,
                curated: /* consume */ curated,
                groups: groups,
                decl: apex.decl,
                bias: apex.bias)
        }

        self.init(
            writings: (apex.overview?.markdown, apex.details?.markdown),
            outlines: outlines,
            halo: halo)
    }
}
extension Unidoc.Cone
{
    var context:Unidoc.RelativePageContext { self.halo.context }

    var overviewText:Unidoc.InertSection<Unidoc.IdentifiableVertices>?
    {
        self.writings.overview.map
        {
            .init(bytecode: $0, outlines: self.outlines, vertices: self.context.vertices)
        }
    }

    var overview:Unidoc.ProseSection?
    {
        self.writings.overview.map
        {
            .init(bytecode: $0, outlines: self.outlines, context: self.context)
        }
    }

    var details:Unidoc.ProseSection?
    {
        self.writings.details.map
        {
            .init(bytecode: $0, outlines: self.outlines, context: self.context)
        }
    }
}
