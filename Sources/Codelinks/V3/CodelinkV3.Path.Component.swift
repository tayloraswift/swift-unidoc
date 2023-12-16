import LexicalPaths

extension CodelinkV3.Path
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
extension CodelinkV3.Path.Component:LexicalContinuation
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .`init`(nil):                  "init"
        case .`init`(let arguments?):       "init" + arguments.description
        case .deinit:                       "deinit"
        case .subscript(nil):               "subscript"
        case .subscript(let arguments?):    "subscript" + arguments.description

        case .nominal(let name, nil):
            name.description

        case .nominal(let name, let arguments?):
            name.description + arguments.description
        }
    }
    @inlinable public
    var unencased:String
    {
        switch self
        {
        case .`init`(nil):                  "init"
        case .`init`(let arguments?):       "init" + arguments.description
        case .deinit:                       "deinit"
        case .subscript(nil):               "subscript"
        case .subscript(let arguments?):    "subscript" + arguments.description

        case .nominal(let name, nil):
            name.unencased

        case .nominal(let name, let arguments?):
            name.unencased + arguments.description
        }
    }
}
extension CodelinkV3.Path.Component:LosslessStringConvertible
{
    public
    init?(_ string:String)
    {
        var codepoints:Substring.UnicodeScalarView = string[...].unicodeScalars
        self.init(parsing: &codepoints)
        if !codepoints.isEmpty
        {
            return nil
        }
    }
}
extension CodelinkV3.Path.Component
{
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        if  let identifier:CodelinkV3.Identifier = .init(parsing: &codepoints)
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
        if  let identifier:CodelinkV3.Operator = .init(parsing: &remaining),
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
