import HTML
import Symbols

extension Unidoc
{
    @dynamicMemberLookup
    struct ExtensionBody
    {
        private
        var lists:Lists
        private
        let name:String

        private
        init(lists:Lists, name:String)
        {
            self.lists = lists
            self.name = name
        }
    }
}
extension Unidoc.ExtensionBody
{
    typealias Lists =
    (
        conformances:Unidoc.SegregatedList,
        protocols:Unidoc.SegregatedList,
        types:Unidoc.SegregatedList,
        typealiases:Unidoc.SegregatedList,
        membersOnType:Unidoc.SegregatedList,
        membersOnInstance:Unidoc.SegregatedList,
        featuresOnType:Unidoc.SegregatedList,
        featuresOnInstance:Unidoc.SegregatedList,
        subtypes:Unidoc.SegregatedList,
        subclasses:Unidoc.SegregatedList,
        overriddenBy:Unidoc.SegregatedList,
        restatedBy:Unidoc.SegregatedList,
        defaultImplementations:Unidoc.SegregatedList
    )
}
extension Unidoc.ExtensionBody
{
    init(extension group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags,
        name:String,
        with context:borrowing Unidoc.InternalPageContext)
    {
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

        self.init(lists: lists, name: name)
    }
}

extension Unidoc.ExtensionBody
{
    private
    subscript(
        dynamicMember keyPath:
        KeyPath<Lists, Unidoc.SegregatedList>) -> Unidoc.SegregatedSection?
    {
        let list:Unidoc.SegregatedList = self.lists[keyPath: keyPath]
        if  list.isEmpty
        {
            return nil
        }

        let type:Unidoc.SegregatedType

        switch keyPath
        {
        case \.conformances:            type = .conformances
        case \.protocols:               type = .protocols
        case \.types:                   type = .types
        case \.typealiases:             type = .typealiases
        case \.membersOnType:           type = .membersOnType
        case \.membersOnInstance:       type = .membersOnInstance
        case \.featuresOnType:          type = .featuresOnType
        case \.featuresOnInstance:      type = .featuresOnInstance
        case \.subtypes:                type = .subtypes
        case \.subclasses:              type = .subclasses
        case \.overriddenBy:            type = .overriddenBy
        case \.restatedBy:              type = .restatedBy
        case \.defaultImplementations:  type = .defaultImplementations
        default:                        return nil
        }

        return .init(list: list, type: type, in: self.name)
    }
}
extension Unidoc.ExtensionBody:HTML.OutputStreamable
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
