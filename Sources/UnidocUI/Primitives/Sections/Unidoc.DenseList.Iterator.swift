extension Unidoc.DenseList
{
    struct Iterator
    {
        private
        let context:Unidoc.PeripheralPageContext
        private
        var cards:(Cards<Unidoc.Scalar>, Cards<Unidoc.ConformingType>)

        init(
            context:Unidoc.PeripheralPageContext,
            members:([Unidoc.Scalar], [Unidoc.ConformingType]))
        {
            self.context = context
            self.cards =
            (
                .init(base: members.0.makeIterator()),
                .init(base: members.1.makeIterator())
            )
            _ = self.cards.0.pull(with: context)
            _ = self.cards.1.pull(with: context)
        }
    }
}
extension Unidoc.DenseList.Iterator:IteratorProtocol
{
    mutating
    func next() -> Unidoc.DenseList.Card?
    {
        switch (self.cards.0.next, self.cards.1.next)
        {
        case (let a?, let b?):
            a.path <= b.path
                ? self.cards.0.pull(with: self.context)
                : self.cards.1.pull(with: self.context)

        case (_?, nil):
            self.cards.0.pull(with: self.context)

        case (nil, _?):
            self.cards.1.pull(with: self.context)

        case (nil, nil):
            nil
        }
    }
}
