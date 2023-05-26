import ModuleGraphs

struct ProductNode:DigraphNode
{
    let id:ProductIdentifier
    let predecessors:[ProductIdentifier]

    init(id:ProductIdentifier, predecessors:[ProductIdentifier])
    {
        self.id = id
        self.predecessors = predecessors
    }
}
