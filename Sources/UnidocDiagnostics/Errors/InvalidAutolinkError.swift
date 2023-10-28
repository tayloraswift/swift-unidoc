@frozen public
struct InvalidAutolinkError<Scalar>:Error where Scalar:Sendable
{
    public
    let expression:String
    public
    let context:Diagnostic.Context<Scalar>

    @inlinable public
    init(expression:String, context:Diagnostic.Context<Scalar>? = nil)
    {
        self.expression = expression
        self.context = context ?? .init()
    }
}
extension InvalidAutolinkError:Equatable where Scalar:Equatable
{
}
extension InvalidAutolinkError:Sendable where Scalar:Sendable
{
}
extension InvalidAutolinkError
{
    @inlinable public
    func symbolicated(with symbolicator:some Symbolicator<Scalar>) -> [Diagnostic]
    {
        [
            .init(.warning, context: self.context.symbolicated(with: symbolicator),
                message: """
                autolink expression '\(self.expression)' could not be parsed
                """)
        ]
    }
}
