extension Records
{
    @frozen public
    struct Masters
    {
        public
        var articles:[Record.Master.Article]
        public
        var cultures:[Record.Master.Culture]
        public
        var decls:[Record.Master.Decl]

        @inlinable public
        init(
            articles:[Record.Master.Article],
            cultures:[Record.Master.Culture],
            decls:[Record.Master.Decl])
        {
            self.articles = articles
            self.cultures = cultures
            self.decls = decls
        }
    }
}
extension Records.Masters
{
    @inlinable public
    var count:Int
    {
        self.articles.count + self.cultures.count + self.decls.count
    }
}
extension Records.Masters:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .articles(self.articles.makeIterator(),
            next: self.cultures.makeIterator(),
            then: self.decls.makeIterator())
    }

    @inlinable public
    var underestimatedCount:Int { self.count }
}
