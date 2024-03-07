import MarkdownABI
import UnidocRecords

extension Swiftinit
{
    public
    struct Mesh
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
extension Swiftinit.Mesh
{
    init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        groups:borrowing [Unidoc.AnyGroup],
        apex:__shared some Unidoc.PrincipalVertex) throws
    {
        let outlines:[Unidoc.Outline]
        switch (apex.overview, apex.details)
        {
        case (let overview?, let details?): outlines = overview.outlines + details.outlines
        case (let overview?, nil):          outlines = overview.outlines
        case (nil, let details?):           outlines = details.outlines
        case (nil, nil):                    outlines = []
        }

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
extension Swiftinit.Mesh
{
    var context:IdentifiablePageContext<Swiftinit.Vertices> { self.halo.context }

    var overview:Markdown.ProseSection?
    {
        self.writings.overview.map
        {
            .init(self.context, bytecode: $0, outlines: self.outlines)
        }
    }

    var details:Markdown.ProseSection?
    {
        self.writings.details.map
        {
            .init(self.context, bytecode: $0, outlines: self.outlines)
        }
    }
}
