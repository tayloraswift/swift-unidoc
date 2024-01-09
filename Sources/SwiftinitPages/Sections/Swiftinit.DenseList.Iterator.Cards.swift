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
    func advance(with context:IdentifiablePageContext<Swiftinit.SecondaryOnly>)
    {
        while   let type:Unidoc.ConformingType = self.base.next()
        {
            if  let link:HTML.Link<UnqualifiedPath> = context.link(decl: type.id)
            {
                self.next = .init(link: link,
                    constraints: context.constraints(type.constraints))
                return
            }
        }

        self.next = nil
    }
    mutating
    func pull(
        with context:IdentifiablePageContext<Swiftinit.SecondaryOnly>) -> Swiftinit.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}
extension Swiftinit.DenseList.Iterator.Cards<Unidoc.Scalar>
{
    private mutating
    func advance(with context:IdentifiablePageContext<Swiftinit.SecondaryOnly>)
    {
        while   let type:Unidoc.Scalar = self.base.next()
        {
            if  let link:HTML.Link<UnqualifiedPath> = context.link(decl: type)
            {
                self.next = .init(link: link, constraints: nil)
                return
            }
        }

        self.next = nil
    }
    mutating
    func pull(
        with context:IdentifiablePageContext<Swiftinit.SecondaryOnly>) -> Swiftinit.DenseList.Card?
    {
        defer { self.advance(with: context) }
        return self.next
    }
}