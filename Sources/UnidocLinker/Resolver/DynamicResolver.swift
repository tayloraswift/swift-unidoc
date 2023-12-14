import CodelinkResolution
import Codelinks
import Doclinks
import Sources
import SymbolGraphs
import Unidoc
import UnidocDiagnostics
import UnidocRecords

struct DynamicResolver:~Copyable
{
    private
    let codelinks:CodelinkResolver<Unidoc.Scalar>
    private(set)
    var context:DynamicLinker

    init(codelinks:CodelinkResolver<Unidoc.Scalar>,
        context:consuming DynamicLinker)
    {
        self.codelinks = codelinks
        self.context = context
    }
}
extension DynamicResolver
{
    private
    var current:DynamicLinker.Snapshot { self.context.current }
}

extension DynamicResolver
{
    mutating
    func link(article:SymbolGraph.Article) ->
    (
        overview:Unidoc.Passage?,
        details:Unidoc.Passage?
    )
    {
        let outlines:[Unidoc.Outline] = article.outlines.map { self.expand($0) }

        let overview:Unidoc.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines[..<article.fold]),
            markdown: article.overview)
        let details:Unidoc.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines[article.fold...]),
            markdown: article.details)
        return (overview, details)
    }

    mutating
    func link(topic:SymbolGraph.Topic) -> (overview:Unidoc.Passage?, members:[Unidoc.VertexLink])
    {
        let overview:Unidoc.Passage? = topic.overview.isEmpty ? nil : .init(
            outlines: topic.outlines.map { self.expand($0) },
            markdown: topic.overview)

        return (overview, topic.members.map { self.resolve($0) })
    }
}
extension DynamicResolver
{
    private mutating
    func expand(_ outline:SymbolGraph.Outline) -> Unidoc.Outline
    {
        func words(in text:String) -> Int
        {
            var length:Int = 1
            for character:Character in text where character == " "
            {
                length += 1
            }
            return length
        }

        switch outline
        {
        case    .scalar(let scalar, text: let text):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .path(text, self.context.expand(scalar, to: words(in: text)))
            }
            else if let _:Int = scalar / .article
            {
                return .path(text, [self.current.id + scalar])
            }
            else if let _:Int = scalar / .file
            {
                //  TODO: implement me
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.namespaces[namespace]
            {
                return .path(text, [scalar])
            }

        case    .vector(let feature, self: let heir, text: let text):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(text, self.context.expand((heir, feature), to: words(in: text)))
            }

        case    .unresolved(let unresolved):
            guard
            let (codelink, resolution):
                (Codelink, CodelinkResolver<Unidoc.Scalar>.Overload.Target?) =
                    self.resolve(unresolved)
            else
            {
                return .text(unresolved.link)
            }

            let text:String = codelink.path.visible.joined(separator: ".")
            let length:Int = codelink.path.visible.count

            switch resolution
            {
            case nil:
                return .text(text)

            case .scalar(let scalar)?:
                return .path(text, self.context.expand(scalar, to: length))

            case .vector(let feature, self: let heir)?:
                return .path(text, self.context.expand((heir, feature), to: length))
            }
        }

        return .text("<unavailable>")
    }

    private mutating
    func resolve(_ outline:SymbolGraph.Outline) -> Unidoc.VertexLink
    {
        switch outline
        {
        case   .scalar(let scalar, text: _):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .scalar(scalar)
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.namespaces[namespace]
            {
                return .scalar(scalar)
            }
            else
            {
                //  The rest of the planes don’t cross packages... yet...
                return .scalar(self.current.id + scalar)
            }

        case    .vector(let feature, self: _, text: _):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature]
            {
                return .scalar(feature)
            }

        case    .unresolved(let unresolved):
            switch self.resolve(unresolved)
            {
            case  nil:
                return .text(unresolved.link)

            case (let codelink, nil)?:
                return .text(codelink.path.visible.joined(separator: "."))

            case (_, .scalar(let scalar)?)?:
                return .scalar(scalar)

            case (_, .vector(let feature, self: _)?)?:
                return .scalar(feature)
            }
        }

        return .text("<unavailable>")
    }

    private mutating
    func resolve(_ unresolved:SymbolGraph.Outline.Unresolved) ->
    (
        codelink:Codelink,
        resolved:CodelinkResolver<Unidoc.Scalar>.Overload.Target?
    )?
    {
        let autolink:Autolink = .init(unresolved,
            location: unresolved.location?.map { self.current.id + $0 })

        guard
        let codelink:Codelink = autolink.parsed
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable codelink!
            self.context.diagnostics[autolink] = InvalidAutolinkError<DynamicSymbolicator>.init(
                expression: unresolved.link)

            return nil
        }

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.context.diagnostics[autolink] = InvalidCodelinkError<DynamicSymbolicator>.init(
                overloads: overloads,
                codelink: codelink)

            return (codelink, nil)

        case .one(let overload):
            return (codelink, overload.target)
        }
    }
}
