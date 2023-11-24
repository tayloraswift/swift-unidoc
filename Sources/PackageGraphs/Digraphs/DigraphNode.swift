public
protocol DigraphNode:Identifiable where ID:Comparable & Sendable
{
    associatedtype Predecessors:Sequence<ID>

    var predecessors:Predecessors { get }
}
extension DigraphNode
{
    @inlinable public static
    func order(topologically nodes:[Self]) throws -> [Self]
    {
        var consumers:[ID: [Self]] = [:]
        var index:[ID: Self] = [:]
        for node:Self in nodes.sorted(by: { $0.id < $1.id })
        {
            if  case _? = index.updateValue(node, forKey: node.id)
            {
                throw DigraphNodeError<Self>.duplicate(node.id)
            }
            for predecessor:ID in node.predecessors.sorted()
            {
                consumers[predecessor, default: []].append(node)
            }
        }
        if  let ordered:[Self] = Self.order(topologically: index, consumers: &consumers)
        {
            return ordered
        }
        else
        {
            throw DigraphCycleError<Self>.init()
        }
    }
    /// Performs a topological sort over the given nodes using the provided edge table.
    /// This operation is destructive for the the edge table.
    @inlinable public static
    func order(topologically nodes:[ID: Self], consumers:inout [ID: [Self]]) -> [Self]?
    {
        var sources:[Self] = []
        var dependencies:[ID: Set<ID>] = nodes.compactMapValues
        {
            //  If `Self` is ``PackageNode``, it is expected for edges to sometimes point
            //  to non-existent nodes.
            let predecessors:[ID] = $0.predecessors.filter(nodes.keys.contains(_:))
            if  predecessors.isEmpty
            {
                sources.append($0)
                return nil
            }
            else
            {
                return .init(predecessors)
            }
        }

        //  Note: polarity reversed
        sources.sort { $1.id < $0.id }

        var ordered:[Self] = [] ; ordered.reserveCapacity(nodes.count)

        while let source:Self = sources.popLast()
        {
            ordered.append(source)

            guard let next:[Self] = consumers.removeValue(forKey: source.id)
            else
            {
                continue
            }
            for next:Self in next
            {
                {
                    if  case _? = $0?.remove(source.id),
                        case true? = $0?.isEmpty
                    {
                        sources.append(next)
                        $0 = nil
                    }
                } (&dependencies[next.id])
            }
        }

        //  Nodes may depend on packages we did not clone. This is completely
        //  normal and expected when packages have things like SPM plugins that
        //  don’t get built by default.
        for id:ID in consumers.keys where nodes.keys.contains(id)
        {
            return nil
        }

        return dependencies.isEmpty ? ordered : nil
    }
}
