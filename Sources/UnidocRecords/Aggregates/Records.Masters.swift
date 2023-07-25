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
        public
        var files:[Record.Master.File]

        @inlinable public
        init(
            articles:[Record.Master.Article],
            cultures:[Record.Master.Culture],
            decls:[Record.Master.Decl],
            files:[Record.Master.File])
        {
            self.articles = articles
            self.cultures = cultures
            self.decls = decls
            self.files = files
        }
    }
}
extension Records.Masters
{
    @inlinable public
    var count:Int
    {
        self.articles.count + self.cultures.count + self.decls.count + self.files.count
    }
}
extension Records.Masters:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .articles(self.articles.makeIterator(),
            cultures: self.cultures.makeIterator(),
            decls: self.decls.makeIterator(),
            files: self.files.makeIterator())
    }

    @inlinable public
    var underestimatedCount:Int { self.count }
}
