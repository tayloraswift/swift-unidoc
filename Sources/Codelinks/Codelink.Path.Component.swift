extension Codelink.Path
{
    @frozen public
    enum Component:Equatable, Hashable, Sendable
    {
        /// An initializer, which is an anonymous path component.
        case `init`(Arguments?)
        /// A deinitializer, which is an anonymous path component.
        case `deinit`
        /// A subscript, which is an anonymous path component.
        case `subscript`(Arguments?)

        /// A nominal path component.
        case  nominal(Basename, Arguments?)
    }
}
extension Codelink.Path.Component:LexicalContinuation
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .`init`(nil):                  return "init"
        case .`init`(let arguments?):       return "init" + arguments.description
        case .deinit:                       return "deinit"
        case .subscript(nil):               return "subscript"
        case .subscript(let arguments?):    return "subscript" + arguments.description

        case .nominal(let name, nil):
            return name.description

        case .nominal(let name, let arguments?):
            return name.description + arguments.description
        }
    }
    @inlinable public
    var unencased:String
    {
        switch self
        {
        case .`init`(nil):                  return "init"
        case .`init`(let arguments?):       return "init" + arguments.description
        case .deinit:                       return "deinit"
        case .subscript(nil):               return "subscript"
        case .subscript(let arguments?):    return "subscript" + arguments.description

        case .nominal(let name, nil):
            return name.unencased

        case .nominal(let name, let arguments?):
            return name.unencased + arguments.description
        }
    }
}
extension Codelink.Path.Component
{
    func lowercased() -> Self
    {
        switch self
        {
        case .`init`(let arguments):
            return .`init`(arguments?.lowercased())
        
        case .deinit:
            return .deinit
        
        case .subscript(let arguments):
            return .subscript(arguments?.lowercased())

        case .nominal(let name, let arguments):
            return .nominal(name.lowercased(), arguments?.lowercased())
        }
    }
}
extension Codelink.Path.Component
{
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        if  let identifier:Codelink.Identifier = .init(parsing: &codepoints)
        {
            switch (identifier.encased, identifier.characters)
            {
            case (false, "init"):
                self = .`init`(.init(parsing: &codepoints))
            
            case (false, "deinit"):
                self = .deinit
            
            case (false, "subscript"):
                self = .subscript(.init(parsing: &codepoints))
            
            case (_, let characters):
                self = .nominal(.init(unencased: characters), .init(parsing: &codepoints))
            }

            return
        }

        var remaining:Substring.UnicodeScalarView = codepoints

        //  operators must always have at least one argument.
        if  let identifier:Codelink.Operator = .init(parsing: &remaining),
            let arguments:Arguments = .init(parsing: &remaining)
        {
            self = .nominal(.init(unencased: identifier.characters), arguments)
            codepoints = remaining
        }
        else
        {
            return nil
        }
    }
}
