extension Unidoc.Volume
{
    @frozen public
    struct Vertices:Sendable
    {
        public
        var articles:[Unidoc.ArticleVertex]
        public
        var cultures:[Unidoc.CultureVertex]
        public
        var decls:[Unidoc.DeclVertex]
        public
        var files:[Unidoc.FileVertex]
        public
        var products:[Unidoc.ProductVertex]
        public
        var foreign:[Unidoc.ForeignVertex]
        public
        var global:Unidoc.GlobalVertex

        @inlinable public
        init(
            articles:[Unidoc.ArticleVertex],
            cultures:[Unidoc.CultureVertex],
            decls:[Unidoc.DeclVertex],
            files:[Unidoc.FileVertex],
            products:[Unidoc.ProductVertex],
            foreign:[Unidoc.ForeignVertex],
            global:Unidoc.GlobalVertex)
        {
            self.articles = articles
            self.cultures = cultures
            self.decls = decls
            self.files = files
            self.products = products
            self.foreign = foreign
            self.global = global
        }
    }
}
