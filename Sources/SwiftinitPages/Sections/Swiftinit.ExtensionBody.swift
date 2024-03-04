import HTML
import Symbols

extension Swiftinit
{
    @dynamicMemberLookup
    struct ExtensionBody
    {
        private
        var lists:Lists

        private
        init(lists:Lists)
        {
            self.lists = lists
        }
    }
}
extension Swiftinit.ExtensionBody
{
    typealias Lists =
    (
        conformances:Swiftinit.SegregatedList,
        protocols:Swiftinit.SegregatedList,
        types:Swiftinit.SegregatedList,
        typealiases:Swiftinit.SegregatedList,
        membersOnType:Swiftinit.SegregatedList,
        membersOnInstance:Swiftinit.SegregatedList,
        featuresOnType:Swiftinit.SegregatedList,
        featuresOnInstance:Swiftinit.SegregatedList,
        subtypes:Swiftinit.SegregatedList,
        subclasses:Swiftinit.SegregatedList,
        overriddenBy:Swiftinit.SegregatedList,
        restatedBy:Swiftinit.SegregatedList,
        defaultImplementations:Swiftinit.SegregatedList
    )
}
extension Swiftinit.ExtensionBody
{
    // var visibleItems:Int
    // {
    //     self.lists.conformances.visible.count
    //     + self.lists.protocols.visible.count
    //     + self.lists.types.visible.count
    //     + self.lists.typealiases.visible.count
    //     + self.lists.membersOnType.visible.count
    //     + self.lists.membersOnInstance.visible.count
    //     + self.lists.featuresOnType.visible.count
    //     + self.lists.featuresOnInstance.visible.count
    //     + self.lists.subtypes.visible.count
    //     + self.lists.subclasses.visible.count
    //     + self.lists.overriddenBy.visible.count
    //     + self.lists.restatedBy.visible.count
    //     + self.lists.defaultImplementations.visible.count
    // }

    init?(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags)
    {
        if  group.isEmpty
        {
            return nil
        }

        var lists:Lists

        lists.conformances = .partition(group.conformances, with: context)

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
                case .instance:         lists.membersOnInstance.append(decl)
                case .class:            lists.membersOnType.append(decl)
                case .static:           lists.membersOnType.append(decl)
                }
            }
            else
            {
                switch decl.vertex.phylum
                {
                case .associatedtype:   lists.membersOnType.append(decl)
                case .enum:             lists.types.append(decl)
                case .struct:           lists.types.append(decl)
                case .class:            lists.types.append(decl)
                case .actor:            lists.types.append(decl)
                case .protocol:         lists.protocols.append(decl)
                default:                lists.typealiases.append(decl)
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
            lists.subtypes = .partition(group.subforms, with: context)
            lists.subclasses = []
            lists.restatedBy = []
            lists.overriddenBy = []
            lists.defaultImplementations = []

        case .class:
            lists.subtypes = []
            lists.subclasses = .partition(group.subforms, with: context)
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
                lists.overriddenBy = .partition(group.subforms, with: context)
            }
        }

        self.init(lists: lists)
    }
}

extension Swiftinit.ExtensionBody
{
    private
    subscript(
        dynamicMember keyPath:
        KeyPath<Lists, Swiftinit.SegregatedList>) -> Swiftinit.SegregatedSection?
    {
        let items:Swiftinit.SegregatedList = self.lists[keyPath: keyPath]
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
extension Swiftinit.ExtensionBody:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
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
