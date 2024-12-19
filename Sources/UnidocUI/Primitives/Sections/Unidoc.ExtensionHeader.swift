import HTML
import Signatures
import Symbols

extension Unidoc
{
    struct ExtensionHeader
    {
        private
        let heading:ExtensionHeading
        private
        let culture:Unidoc.LinkReference<Unidoc.CultureVertex>
        private
        let `where`:Unidoc.WhereClause?

        let name:String

        private
        init(
            heading:ExtensionHeading,
            culture:Unidoc.LinkReference<Unidoc.CultureVertex>,
            where clause:Unidoc.WhereClause?,
            name:String)
        {
            self.heading = heading
            self.culture = culture
            self.where = clause
            self.name = name
        }
    }
}
extension Unidoc.ExtensionHeader
{
    init(extension group:borrowing Unidoc.ExtensionGroup,
        culture:Unidoc.LinkReference<Unidoc.CultureVertex>,
        module:Symbol.Module,
        bias:Unidoc.Bias,
        with context:__shared Unidoc.InternalPageContext)
    {
        var first:Bool = true
        var name:String = "\(module)"

        for requirement:GenericConstraint<Unidoc.Scalar> in group.constraints
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

        self.init(
            heading: .init(culture: group.culture, bias: bias),
            culture: culture,
            where: group.constraints | context,
            name: name)
    }
}
extension Unidoc.ExtensionHeader:Identifiable
{
    var id:String { "se:\(self.name)" }
}
extension Unidoc.ExtensionHeader:HTML.OutputStreamableAnchor
{
    static
    func += (header:inout HTML.ContentEncoder, self:Self)
    {
        header[.h2]
        {
            let name:String

            switch self.heading
            {
            case .citizens:     name = "Citizens"
            case .available:    name = "Available"
            case .extension:    name = "Extension"
            }

            $0[.a] { $0.href = "#\(self.id)" } = name
            $0 += " in "
            $0[.a] { $0.href = self.culture.target?.url } = "\(self.culture.vertex.module.id)"
        }

        header[.div, .code] { $0.class = "constraints" } = self.where
    }
}
