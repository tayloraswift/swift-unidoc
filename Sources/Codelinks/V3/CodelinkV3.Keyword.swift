extension CodelinkV3
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
extension CodelinkV3.Keyword
{
    init?(_ string:Substring)
    {
        switch string
        {
        case "actor":           self = .actor
        case "associatedtype":  self = .associatedtype
        case "case":            self = .case
        case "class":           self = .class
        case "enum":            self = .enum
        case "func":            self = .func
        case "import":          self = .import
        case "macro":           self = .macro
        case "protocol":        self = .protocol
        case "static":          self = .static
        case "struct":          self = .struct
        case "typealias":       self = .typealias
        case "var":             self = .var
        case _:                 return nil
        }
    }
}
extension CodelinkV3.Keyword
{
    var encased:String
    {
        "`\(self.rawValue)`"
    }
}
