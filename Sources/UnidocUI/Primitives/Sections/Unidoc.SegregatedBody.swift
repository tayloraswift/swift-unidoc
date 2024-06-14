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
        let name:String?

        private
        init(lists:Lists, count:Int, name:String?)
        {
            self.lists = lists
            self.count = count
            self.name = name
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
        self.lists.protocols.length +
        self.lists.types.length +
        self.lists.typealiases.length +
        self.lists.macros.length +
        self.lists.membersOnType.length +
        self.lists.membersOnInstance.length +
        self.lists.globals.length
    }
}
extension Unidoc.SegregatedBody
{
    init?(group:__shared [Unidoc.Scalar],
        name:String? = nil,
        with context:borrowing Unidoc.InternalPageContext)
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

        self.init(lists: lists, count: group.count, name: name)
    }
}
extension Unidoc.SegregatedBody
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
        case \.protocols:               type = .protocols
        case \.types:                   type = .types
        case \.typealiases:             type = .typealiases
        case \.macros:                  type = .macros
        case \.membersOnType:           type = .membersOnType
        case \.membersOnInstance:       type = .membersOnInstance
        case \.globals:                 type = .globals
        default:                        return nil
        }

        return .init(list: list, type: type, in: self.name)
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
