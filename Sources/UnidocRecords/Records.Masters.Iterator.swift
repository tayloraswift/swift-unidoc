extension Records.Masters
{
    @frozen public
    enum Iterator
    {
        case articles(IndexingIterator<[Record.Master.Article]>,
            next:IndexingIterator<[Record.Master.Culture]>,
            then:IndexingIterator<[Record.Master.Decl]>)
        case cultures(IndexingIterator<[Record.Master.Culture]>,
            then:IndexingIterator<[Record.Master.Decl]>)
        case decls(IndexingIterator<[Record.Master.Decl]>)
        case exhausted
    }
}
extension Records.Masters.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> Record.Master?
    {
        switch self
        {
        case .articles(var iterator, next: let next, then: let then):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                self = .cultures(next, then: then)
                return self.next()
            case let element?:
                self = .articles(iterator, next: next, then: then)
                return .article(element)
            }

        case .cultures(var iterator, then: let next):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                self = .decls(next)
                return self.next()
            case let element?:
                self = .cultures(iterator, then: next)
                return .culture(element)
            }

        case .decls(var iterator):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                return nil
            case let element?:
                self = .decls(iterator)
                return .decl(element)
            }

        case .exhausted:
            return nil
        }
    }
}
