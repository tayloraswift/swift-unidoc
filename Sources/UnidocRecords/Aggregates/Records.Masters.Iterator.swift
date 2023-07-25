extension Records.Masters
{
    @frozen public
    enum Iterator
    {
        case articles(IndexingIterator<[Record.Master.Article]>,
            cultures:IndexingIterator<[Record.Master.Culture]>,
            decls:IndexingIterator<[Record.Master.Decl]>,
            files:IndexingIterator<[Record.Master.File]>)

        case cultures(IndexingIterator<[Record.Master.Culture]>,
            decls:IndexingIterator<[Record.Master.Decl]>,
            files:IndexingIterator<[Record.Master.File]>)

        case decls(IndexingIterator<[Record.Master.Decl]>,
            files:IndexingIterator<[Record.Master.File]>)

        case files(IndexingIterator<[Record.Master.File]>)

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
        case .articles(var iterator, let cultures, let decls, let files):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                self = .cultures(cultures, decls: decls, files: files)
                return self.next()
            case let element?:
                self = .articles(iterator, cultures: cultures, decls: decls, files: files)
                return .article(element)
            }

        case .cultures(var iterator, let decls, let files):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                self = .decls(decls, files: files)
                return self.next()
            case let element?:
                self = .cultures(iterator, decls: decls, files: files)
                return .culture(element)
            }

        case .decls(var iterator, let files):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                self = .files(files)
                return self.next()
            case let element?:
                self = .decls(iterator, files: files)
                return .decl(element)
            }

        case .files(var iterator):
            self = .exhausted
            switch iterator.next()
            {
            case nil:
                return nil
            case let element?:
                self = .files(iterator)
                return .file(element)
            }

        case .exhausted:
            return nil
        }
    }
}
