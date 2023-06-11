extension Compiler
{
    @frozen public
    struct Namespace:Identifiable, Sendable
    {
        public
        let scalars:[Compiler.Scalar]
        public
        let id:ID

        init(scalars:[Compiler.Scalar], id:ID)
        {
            self.scalars = scalars
            self.id = id
        }
    }
}
extension Compiler.Namespace
{
    /// The index of the namespace module, if it is an included culture.
    var index:Int? { self.id.index }
}
