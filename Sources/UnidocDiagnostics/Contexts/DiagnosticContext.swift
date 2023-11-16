import Sources

@frozen public
struct DiagnosticContext<Symbolicator> where Symbolicator:DiagnosticSymbolicator
{
    @usableFromInline internal
    var unsymbolicated:[Group]

    @inlinable internal
    init(unsymbolicated:[Group])
    {
        self.unsymbolicated = unsymbolicated
    }
}
extension DiagnosticContext
{
    @inlinable public
    init()
    {
        self.init(unsymbolicated: [])
    }
}
extension DiagnosticContext
{
    @inlinable public static
    func += (self:inout Self, other:consuming Self)
    {
        self.unsymbolicated += other.unsymbolicated
    }
}
extension DiagnosticContext
{
    @inlinable public
    subscript(
        node:some DiagnosticSubject<Symbolicator.Address>) -> (any Diagnostic<Symbolicator>)?
    {
        get
        {
            nil
        }
        set(value)
        {
            guard
            let value:any Diagnostic<Symbolicator>
            else
            {
                return
            }

            self.unsymbolicated.append(.contextual(value,
                location: node.location,
                context: node.context))
        }
    }
    @inlinable public
    subscript(node:Never?) -> (any Diagnostic<Symbolicator>)?
    {
        get
        {
            nil
        }
        set(value)
        {
            guard
            let value:any Diagnostic<Symbolicator>
            else
            {
                return
            }

            self.unsymbolicated.append(.general(value))
        }
    }
}