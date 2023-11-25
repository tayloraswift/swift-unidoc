import Symbols

struct ProductNode:DigraphNode
{
    let id:Symbol.Product
    let predecessors:[Symbol.Product]

    init(id:Symbol.Product, predecessors:[Symbol.Product])
    {
        self.id = id
        self.predecessors = predecessors
    }
}
