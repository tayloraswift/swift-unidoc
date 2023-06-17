import Codelinks

public
protocol CodelinkResolver<Address>
{
    associatedtype Address:Equatable, Hashable, Sendable

    subscript(path:[String]) -> Overload<Address>.Accumulator
    {
        get
    }
}
extension CodelinkResolver
{
    public
    func query(ascending scope:[String] = [], link:Codelink) -> Overloads<Address>?
    {
        for index:Int in (scope.startIndex ... scope.endIndex).reversed()
        {
            let prefix:ArraySlice = scope.prefix(upTo: index)
            let path:[String]

            switch (prefix, link.scope)
            {
            case ([], nil):
                path = .init                              (link.path.components)

            case ([], let scope?):
                path = .init          (scope.components) + link.path.components

            case (_ , let scope?):
                path = .init(prefix) + scope.components  + link.path.components

            case (_ , nil):
                path = .init(prefix) +                     link.path.components
            }

            if  let overloads:Overloads<Address> = .init(self.query(path,
                    filter: link.filter,
                    hash: link.hash))
            {
                return overloads
            }
        }
        return nil
    }
    private
    func query(_ path:[String],
        filter:Codelink.Filter?,
        hash:Codelink.Hash?) -> Overload<Address>.Accumulator
    {
        switch (self[path], hash, filter)
        {
        case (.many(let overloads), let hash?,  _):
            return .init(filtering: overloads) { hash == $0.hash }

        case (.many(let overloads), nil,        let filter?):
            return .init(filtering: overloads) { filter ~= $0.phylum }

        case (      let overloads,  _,          _):
            return overloads
        }
    }
}
