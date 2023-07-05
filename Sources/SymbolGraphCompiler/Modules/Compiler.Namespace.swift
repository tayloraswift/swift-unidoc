extension Compiler
{
    @frozen public
    struct Namespace:Identifiable, Sendable
    {
        public
        let decls:[Compiler.Decl]
        public
        let id:ID

        init(decls:[Compiler.Decl], id:ID)
        {
            self.decls = decls
            self.id = id
        }
    }
}
extension Compiler.Namespace
{
    /// The index of the namespace module, if it is an included culture.
    var index:Int? { self.id.index }
}
