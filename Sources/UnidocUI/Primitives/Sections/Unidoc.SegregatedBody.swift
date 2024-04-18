import HTML
import Symbols

extension Unidoc
{
    @dynamicMemberLookup
    struct SegregatedBody
    {
        let lists:Lists
        /// Cached for performance.
        let count:Int

        private
        init(lists:Lists, count:Int)
        {
            self.lists = lists
            self.count = count
        }
    }
}
extension Unidoc.SegregatedBody
{
    typealias Lists =
    (
        protocols:Unidoc.SegregatedList,
        types:Unidoc.SegregatedList,
        typealiases:Unidoc.SegregatedList,
        macros:Unidoc.SegregatedList,
        membersOnType:Unidoc.SegregatedList,
        membersOnInstance:Unidoc.SegregatedList,
        globals:Unidoc.SegregatedList
    )
}
extension Unidoc.SegregatedBody:Unidoc.CollapsibleContent
{
    var length:Int
    {
        self.lists.protocols.visible.count
        + self.lists.types.visible.count
        + self.lists.typealiases.visible.count
        + self.lists.macros.visible.count
        + self.lists.membersOnType.visible.count
        + self.lists.membersOnInstance.visible.count
        + self.lists.globals.visible.count
    }
}
extension Unidoc.SegregatedBody
{
    init?(_ context:Unidoc.RelativePageContext,
        group:__shared [Unidoc.Scalar])
    {
        if  group.isEmpty
        {
            return nil
        }

        var lists:Lists = ([], [], [], [], [], [], [])

        for id:Unidoc.Scalar in group
        {
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
                case .protocol:         lists.protocols.append(decl)
                case .enum:             lists.types.append(decl)
                case .struct:           lists.types.append(decl)
                case .class:            lists.types.append(decl)
                case .actor:            lists.types.append(decl)
                case .typealias:        lists.typealiases.append(decl)
                case .macro:            lists.macros.append(decl)
                default:                lists.globals.append(decl)
                }
            }
        }

        self.init(lists: lists, count: group.count)
    }
}
extension Unidoc.SegregatedBody
{
    private
    subscript(
        dynamicMember keyPath:
        KeyPath<Lists, Unidoc.SegregatedList>) -> Unidoc.SegregatedSection?
    {
        let items:Unidoc.SegregatedList = self.lists[keyPath: keyPath]
        if  items.isEmpty
        {
            return nil
        }

        let heading:String
        switch keyPath
        {
        case \.protocols:               heading = "Protocols"
        case \.types:                   heading = "Types"
        case \.typealiases:             heading = "Typealiases"
        case \.macros:                  heading = "Macros"
        case \.membersOnType:           heading = "Type members"
        case \.membersOnInstance:       heading = "Instance members"
        case \.globals:                 heading = "Globals"
        default:                        heading = "?"
        }

        return .init(heading: heading, items: items)
    }
}
extension Unidoc.SegregatedBody:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section ?= self.protocols
        section ?= self.types
        section ?= self.typealiases
        section ?= self.macros
        section ?= self.membersOnType
        section ?= self.membersOnInstance
        section ?= self.globals
    }
}
