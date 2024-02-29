import HTML
import Signatures
import Symbols

extension Swiftinit
{
    @dynamicMemberLookup
    struct ExtensionGroup
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>
        let heading:ExtensionHeading
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
        let lists:Lists

        private
        init(
            context:IdentifiablePageContext<Swiftinit.Vertices>,
            heading:ExtensionHeading,
            constraints:[GenericConstraint<Unidoc.Scalar?>],
            lists:Lists)
        {
            self.context = context
            self.heading = heading
            self.constraints = constraints
            self.lists = lists
        }
    }
}
extension Swiftinit.ExtensionGroup
{
    typealias Lists =
    (
        conformances:List.Items,
        protocols:List.Items,
        types:List.Items,
        typealiases:List.Items,
        membersOnType:List.Items,
        membersOnInstance:List.Items,
        featuresOnType:List.Items,
        featuresOnInstance:List.Items,
        subtypes:List.Items,
        subclasses:List.Items,
        overriddenBy:List.Items,
        restatedBy:List.Items,
        defaultImplementations:List.Items
    )
}
extension Swiftinit.ExtensionGroup
{
    init?(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags,
        bias:Swiftinit.Bias)
    {
        if  group.isEmpty
        {
            return nil
        }

        let heading:Swiftinit.ExtensionHeading = .init(culture: group.culture, bias: bias)
        var lists:Lists

        lists.conformances = group.conformances.reduce(into: [])
        {
            $0.append(context.card(decl: $1))
        }

        lists.protocols = []
        lists.types = []
        lists.typealiases = []
        lists.membersOnType = []
        lists.membersOnInstance = []

        for id:Unidoc.Scalar in group.nested
        {
            //  We should never see anything in an extension group that isn't a declaration.
            guard
            case .decl(let decl)? = context.card(id)
            else
            {
                continue
            }

            if  let objectivity:Phylum.Decl.Objectivity = decl.vertex.phylum.objectivity
            {
                switch objectivity
                {
                case .static:   lists.membersOnType.append(decl)
                case .class:    lists.membersOnType.append(decl)
                case .instance: lists.membersOnInstance.append(decl)
                }
            }
            else
            {
                switch decl.vertex.phylum
                {
                case .enum:     lists.types.append(decl)
                case .struct:   lists.types.append(decl)
                case .class:    lists.types.append(decl)
                case .actor:    lists.types.append(decl)
                case .protocol: lists.protocols.append(decl)
                default:        lists.typealiases.append(decl)
                }
            }
        }

        lists.featuresOnType = []
        lists.featuresOnInstance = []

        for id:Unidoc.Scalar in group.features
        {
            if  case .decl(let decl)? = context.card(id)
            {
                switch decl.vertex.phylum.objectivity
                {
                //  In theory, typealiases can be inherited as features.
                case nil:           lists.featuresOnType.append(decl)
                case .static?:      lists.featuresOnType.append(decl)
                case .class?:       lists.featuresOnType.append(decl)
                case .instance?:    lists.featuresOnInstance.append(decl)
                }
            }
        }

        switch decl.phylum
        {
        case .protocol:
            lists.subtypes = group.subforms.reduce(into: [])
            {
                $0.append(context.card(decl: $1))
            }
            lists.subclasses = []
            lists.restatedBy = []
            lists.overriddenBy = []
            lists.defaultImplementations = []

        case .class:
            lists.subtypes = []
            lists.subclasses = group.subforms.reduce(into: [])
            {
                $0.append(context.card(decl: $1))
            }
            lists.restatedBy = []
            lists.overriddenBy = []
            lists.defaultImplementations = []

        default:
            lists.subtypes = []
            lists.subclasses = []
            lists.restatedBy = []
            lists.defaultImplementations = []

            if  decl.kinks[is: .required]
            {
                for id:Unidoc.Scalar in group.subforms
                {
                    if  case .decl(let member)? = context.card(id)
                    {
                        member.vertex.kinks[is: .intrinsicWitness]
                        ? lists.defaultImplementations.append(member)
                        : lists.restatedBy.append(member)
                    }
                }

                lists.overriddenBy = []
            }
            else
            {
                lists.overriddenBy = group.subforms.reduce(into: [])
                {
                    $0.append(context.card(decl: $1))
                }
            }
        }

        self.init(
            context: context,
            heading: heading,
            constraints: group.constraints,
            lists: lists)
    }
}
extension Swiftinit.ExtensionGroup
{
    private
    subscript(dynamicMember keyPath:KeyPath<Lists, List.Items>) -> List?
    {
        let items:List.Items = self.lists[keyPath: keyPath]
        if  items.isEmpty
        {
            return nil
        }

        let heading:String
        switch keyPath
        {
        case \.conformances:            heading = "Conformances"
        case \.protocols:               heading = "Protocols"
        case \.types:                   heading = "Types"
        case \.typealiases:             heading = "Typealiases"
        case \.membersOnType:           heading = "Type members"
        case \.membersOnInstance:       heading = "Instance members"
        case \.featuresOnType:          heading = "Type features"
        case \.featuresOnInstance:      heading = "Instance features"
        case \.subtypes:                heading = "Subtypes"
        case \.subclasses:              heading = "Subclasses"
        case \.overriddenBy:            heading = "Overridden by"
        case \.restatedBy:              heading = "Restated by"
        case \.defaultImplementations:  heading = "Default implementations"
        default:                        heading = "?"
        }

        return .init(heading: heading, items: items)
    }
}
extension Swiftinit.ExtensionGroup:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h2]
        {
            let module:Unidoc.Scalar

            switch self.heading
            {
            case .citizens(in: let culture):
                $0 += "Citizens in "
                module = culture

            case .available(in: let culture):
                $0 += "Available in "
                module = culture

            case .extension(in: let culture):
                $0 += "Extension in "
                module = culture
            }

            $0 ?= self.context.link(module: module)
        }

        section[.div, .code]
        {
            $0.class = "constraints"
        } = Swiftinit.ConstraintsList.init(self.context, constraints: self.constraints)

        section ?= self.conformances
        section ?= self.protocols
        section ?= self.types
        section ?= self.typealiases
        section ?= self.membersOnType
        section ?= self.membersOnInstance
        section ?= self.featuresOnType
        section ?= self.featuresOnInstance
        section ?= self.subtypes
        section ?= self.subclasses
        section ?= self.overriddenBy
        section ?= self.restatedBy
        section ?= self.defaultImplementations
    }
}
