@frozen public
struct Projection:Sendable
{
    public
    let extensions:[Extension]
    public
    let decls:[Decl]

    @inlinable public
    init(extensions:[Extension], decls:[Decl])
    {
        self.extensions = extensions
        self.decls = decls
    }
}
