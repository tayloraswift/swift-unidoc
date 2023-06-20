import ModuleGraphs

extension StaticLinker
{
    @frozen public
    enum BindingError:Error, Sendable
    {
        case expression(String)
        case resolution(String, ModuleIdentifier, Resolution?)
    }
}
extension StaticLinker.BindingError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .expression(let text):
            return """
                Article binding '\(text)' could not be parsed.
                """

        case .resolution(let text, let culture, nil):
            return """
                Article binding '\(text)' does not refer to a declaration \
                in its module, \(culture).
                """

        case .resolution(let text, _, .vector(_)?):
            return """
                Article binding '\(text)' cannot refer to a vector symbol.
                """

        case .resolution(let text, _, .ambiguous(_)?):
            return """
                Article binding '\(text)' is ambiguous.
                """
        }
    }
}
