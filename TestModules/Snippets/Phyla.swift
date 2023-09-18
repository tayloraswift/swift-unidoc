infix operator <- : AssignmentPrecedence
prefix operator ?/
postfix operator /?

public
var Var:Void { return }

public
func Func()
{
}

public prefix
func ?/ (self:Never)
{
}
public
func <- (lhs:Never, rhs:Never)
{
}
public postfix
func /? (self:Never)
{
}

public
typealias Typealias = Any

public
protocol Protocol
{
    associatedtype AssociatedType
}

public
enum Enum
{
    case `case`
}

public
struct Struct
{
    public static prefix
    func ?/ (self:Struct)
    {
    }
    public static
    func <- (lhs:Struct, rhs:Never)
    {
    }
    public static postfix
    func /? (self:Struct)
    {
    }

    public static
    func staticMethod()
    {
    }

    public static
    var staticProperty:Void { return }

    public static
    subscript(_:Never) -> Void
    {
        return
    }

    public
    func instanceMethod()
    {
    }

    public
    var instanceProperty:Void { return }

    public
    subscript() -> Void
    {
        return
    }
}

public
class Class
{
    public
    init()
    {
    }

    public class
    subscript(_:Never) -> Void
    {
        return
    }

    public class
    func classMethod()
    {
    }

    public class
    var classProperty:Void { return }

    deinit
    {
    }
}

public
actor Actor
{
    public
    init()
    {
    }

    deinit
    {
    }
}

@attached(extension) public
macro Macro<T>(_:T.Type) = ModuleName.MacroName

extension Int:Protocol
{
    public
    typealias AssociatedType = Enum
}
