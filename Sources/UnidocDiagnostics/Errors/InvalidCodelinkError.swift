import CodelinkResolution
import Codelinks

@frozen public
struct InvalidCodelinkError<Scalar>:Error, Equatable where Scalar:Hashable
{
    public
    let overloads:[CodelinkResolver<Scalar>.Overload]
    public
    let codelink:Codelink
    public
    let context:Diagnostic.Context<Scalar>

    @inlinable public
    init(overloads:[CodelinkResolver<Scalar>.Overload],
        codelink:Codelink,
        context:Diagnostic.Context<Scalar>? = nil)
    {
        self.overloads = overloads
        self.codelink = codelink
        self.context = context ?? .init()
    }
}
extension InvalidCodelinkError:Sendable where Scalar:Sendable
{
}
extension InvalidCodelinkError
{
    @inlinable public
    func symbolicated(with symbolicator:some Symbolicator<Scalar>) -> [Diagnostic]
    {
        [
            .init(.warning, context: self.context.symbolicated(with: symbolicator),
                message: self.overloads.isEmpty ?
                """
                codelink '\(self.codelink)' does not refer to any known declarations
                """ :
                """
                codelink '\(self.codelink)' is ambiguous
                """)
        ]
        +
        self.overloads.map
        {
            let fixit:Codelink = .init(
                filter: self.codelink.filter,
                scope: self.codelink.scope,
                path: self.codelink.path,
                hash: $0.hash)
            switch $0.target
            {
            case    .scalar(let scalar),
                    .vector(let scalar, self: _):
                return .init(message: """
                    did you mean '\(fixit)'? (\(symbolicator.signature(of: scalar)))
                    """)
            }
        }
    }
}
