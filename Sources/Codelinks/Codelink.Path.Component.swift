extension Codelink.Path
{
    @frozen public
    enum Component:Equatable, Hashable, Sendable
    {
        case `init`(Arguments?)
        case `deinit`
        case `subscript`(Arguments?)

        case  nominal(String, Arguments?)
    }
}
extension Codelink.Path.Component:CustomStringConvertible
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

        case .nominal(let name, nil):               return name
        case .nominal(let name, let arguments?):    return name + arguments.description
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
                self = .nominal(characters, .init(parsing: &codepoints))
            }

            return
        }

        var remaining:Substring.UnicodeScalarView = codepoints

        //  operators must always have at least one argument.
        if  let identifier:Codelink.Operator = .init(parsing: &remaining),
            let arguments:Arguments = .init(parsing: &remaining)
        {
            self = .nominal(identifier.characters, arguments)
            codepoints = remaining
        }
        else
        {
            return nil
        }
    }
}
