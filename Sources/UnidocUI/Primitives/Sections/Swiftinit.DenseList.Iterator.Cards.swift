import HTML
import LexicalPaths

extension Unidoc.DenseList.Iterator
{
    struct Cards<Element>
    {
        private
        var base:IndexingIterator<[Element]>
        private(set)
        var next:Unidoc.DenseList.Card?

        init(base:consuming IndexingIterator<[Element]>)
        {
            self.base = base
            self.next = nil
        }
    }
}
extension Unidoc.DenseList.Iterator.Cards<Unidoc.ConformingType>
{
    private mutating
    func advance(with context:some Unidoc.VertexContext)
    {
        while   let type:Unidoc.ConformingType = self.base.next()
        {
            if  let next:Unidoc.DenseList.Card = .init(type.id,
                    constraints: type.constraints,
                    with: context)
            {
                self.next = next
                return
            }
        }

        self.next = nil
    }
    mutating
    func pull(with context:some Unidoc.VertexContext) -> Unidoc.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}
extension Unidoc.DenseList.Iterator.Cards<Unidoc.Scalar>
{
    private mutating
    func advance(with context:some Unidoc.VertexContext)
    {
        while   let type:Unidoc.Scalar = self.base.next()
        {
            if  let next:Unidoc.DenseList.Card = .init(type, with: context)
            {
                self.next = next
                return
            }
        }

        self.next = nil
    }
    mutating
    func pull(with context:some Unidoc.VertexContext) -> Unidoc.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}