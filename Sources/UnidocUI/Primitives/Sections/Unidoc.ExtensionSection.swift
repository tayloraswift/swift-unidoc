import HTML
import Signatures
import Symbols

extension Unidoc
{
    struct ExtensionSection
    {
        let header:ExtensionHeader
        let body:ExtensionBody

        private
        init(header:ExtensionHeader, body:ExtensionBody)
        {
            self.header = header
            self.body = body
        }
    }
}
extension Unidoc.ExtensionSection
{
    //  https://github.com/apple/swift/issues/74438
    init?(group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags,
        bias:Unidoc.Bias,
        with context:__shared Unidoc.InternalPageContext)
    {
        guard
        let culture:Unidoc.LinkReference<Unidoc.CultureVertex> = context[culture: group.culture]
        else
        {
            return nil
        }

        var name:String = "\(culture.vertex.module.id)"
        var first:Bool = true

        for requirement:GenericConstraint<Unidoc.Scalar?> in group.constraints
        {
            let requirement:Unidoc.WhereClause.Requirement = requirement | context

            if  first
            {
                first = false
                name += " where "
            }
            else
            {
                name += ", "
            }

            name += requirement.parameter

            switch requirement.what
            {
            case .conformer:    name += ":"
            case .subclass:     name += ":"
            case .equal:        name += " == "
            }

            name += "\(requirement.whom.display)"
        }

        guard
        let body:Unidoc.ExtensionBody = .init(group: group,
            decl: decl,
            name: name,
            with: context)
        else
        {
            return nil
        }

        self.init(header: .init(
                heading: .init(culture: group.culture, bias: bias),
                culture: culture,
                where: group.constraints | context,
                id: "se:\(name)"),
            body: body)
    }
}
extension Unidoc.ExtensionSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.header] = self.header
        section += self.body
    }
}
