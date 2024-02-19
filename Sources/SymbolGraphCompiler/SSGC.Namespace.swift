extension SSGC
{
    @frozen public
    struct Namespace:Identifiable, Sendable
    {
        public
        let decls:[Decl]
        public
        let id:ID

        init(decls:[Decl], id:ID)
        {
            self.decls = decls
            self.id = id
        }
    }
}
extension SSGC.Namespace
{
    /// The index of the namespace module, if it is an included culture.
    var index:Int? { self.id.index }
}
