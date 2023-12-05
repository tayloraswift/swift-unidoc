extension Volume
{
    @frozen public
    struct Vertices:Sendable
    {
        public
        var articles:[Vertex.Article]
        public
        var cultures:[Vertex.Culture]
        public
        var decls:[Vertex.Decl]
        public
        var files:[Vertex.File]
        public
        var foreign:[Vertex.Foreign]
        public
        var global:Vertex.Global

        @inlinable public
        init(
            articles:[Vertex.Article],
            cultures:[Vertex.Culture],
            decls:[Vertex.Decl],
            files:[Vertex.File],
            foreign:[Vertex.Foreign],
            global:Vertex.Global)
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
