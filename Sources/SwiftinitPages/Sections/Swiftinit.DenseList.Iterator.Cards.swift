import HTML
import LexicalPaths

extension Swiftinit.DenseList.Iterator
{
    struct Cards<Element>
    {
        private
        var base:IndexingIterator<[Element]>
        private(set)
        var next:Swiftinit.DenseList.Card?

        init(base:consuming IndexingIterator<[Element]>)
        {
            self.base = base
            self.next = nil
        }
    }
}
extension Swiftinit.DenseList.Iterator.Cards<Unidoc.ConformingType>
{
    private mutating
    func advance(with context:some Unidoc.VertexContext)
    {
        while   let type:Unidoc.ConformingType = self.base.next()
        {
            if  let next:Swiftinit.DenseList.Card = .init(type.id,
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
    func pull(with context:some Unidoc.VertexContext) -> Swiftinit.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}
extension Swiftinit.DenseList.Iterator.Cards<Unidoc.Scalar>
{
    private mutating
    func advance(with context:some Unidoc.VertexContext)
    {
        while   let type:Unidoc.Scalar = self.base.next()
        {
            if  let next:Swiftinit.DenseList.Card = .init(type, with: context)
            {
                self.next = next
                return
            }
        }

        self.next = nil
    }
    mutating
    func pull(with context:some Unidoc.VertexContext) -> Swiftinit.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}