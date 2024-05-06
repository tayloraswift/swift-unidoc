import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Tooltips
    {
        public
        var cultures:[CultureVertex]
        public
        var decls:[DeclVertex]

        @inlinable public
        init(cultures:[CultureVertex] = [], decls:[DeclVertex] = [])
        {
            self.cultures = cultures
            self.decls = decls
        }
    }
}

