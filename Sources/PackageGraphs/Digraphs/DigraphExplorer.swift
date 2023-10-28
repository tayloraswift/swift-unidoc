/// Context for a breadth-first traversal of a digraph.
@frozen public
struct DigraphExplorer<Node> where Node:DigraphNode, Node.ID:Sendable
{
    @usableFromInline internal
    let nodes:Nodes

    /// Nodes that have been fully explored. Once ``queued`` becomes
    /// empty again, this will contain every node of interest.
    @usableFromInline internal
    var visited:[Node.ID: Node]
    /// Nodes that have been discovered, but not explored through.
    @usableFromInline internal
    var queued:[Node]

    @inlinable public
    init(nodes:Nodes)
    {
        self.nodes = nodes

        self.visited = [:]
        self.queued = []
    }
}
extension DigraphExplorer
{
    /// Enqueues the given node if it has not already been visited.
    @inlinable public mutating
    func explore(node:Node)
    {
        {
            if  case nil = $0
            {
                self.queued.append(node)
                $0 = node
            }
        } (&self.visited[node.id])
    }
    /// Looks up and enqueues the given node if it has not already been visited.
    /// No lookup happens if the node has already been visited.
    @inlinable public mutating
    func explore(node id:Node.ID) throws
    {
        try
        {
            if  case nil = $0
            {
                let node:Node = try self.nodes(id)
                self.queued.append(node)
                $0 = node
            }
        } (&self.visited[id])
    }

    @inlinable public mutating
    func conquer(by advance:(inout Self, Node) throws -> ()) rethrows -> [Node.ID: Node]
    {
        while let node:Node = self.queued.popLast()
        {
            try advance(&self, node)
        }
        return self.visited
    }
}
