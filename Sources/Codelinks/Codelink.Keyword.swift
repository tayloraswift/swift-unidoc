extension Codelink
{
    enum Keyword:String
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case `enum`
        case `func`
        case `import`
        case  macro
        case `protocol`
        case `static`
        case `struct`
        case `typealias`
        case `var`
    }
}
extension Codelink.Keyword
{
    init?(_ identifier:Codelink.Identifier)
    {
        if !identifier.encased
        {
            self.init(rawValue: identifier.unencased)
        }
        else
        {
            return nil
        }
    }
    init?(_ scope:Codelink.Scope)
    {
        if scope.components.prefix.isEmpty
        {
            self.init(scope.components.last)
        }
        else
        {
            return nil
        }
    }

    var encased:String
    {
        "`\(self.rawValue)`"
    }
}
