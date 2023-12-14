extension Unidoc.Volume
{
    @frozen public
    struct Vertices:Sendable
    {
        public
        var articles:[Unidoc.Vertex.Article]
        public
        var cultures:[Unidoc.Vertex.Culture]
        public
        var decls:[Unidoc.Vertex.Decl]
        public
        var files:[Unidoc.Vertex.File]
        public
        var foreign:[Unidoc.Vertex.Foreign]
        public
        var global:Unidoc.Vertex.Global

        @inlinable public
        init(
            articles:[Unidoc.Vertex.Article],
            cultures:[Unidoc.Vertex.Culture],
            decls:[Unidoc.Vertex.Decl],
            files:[Unidoc.Vertex.File],
            foreign:[Unidoc.Vertex.Foreign],
            global:Unidoc.Vertex.Global)
        {
            self.articles = articles
            self.cultures = cultures
            self.decls = decls
            self.files = files
            self.foreign = foreign
            self.global = global
        }
    }
}
