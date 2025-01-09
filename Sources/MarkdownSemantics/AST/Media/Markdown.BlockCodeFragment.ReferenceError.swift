extension Markdown.BlockCodeFragment
{
    enum ReferenceError:Error
    {
        case snippet(undefined:String?, available:[String])
        case slice(undefined:String, available:[String])
    }
}
extension Markdown.BlockCodeFragment.ReferenceError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .snippet(nil, let available):
            """
            no snippet 'id' or 'path' is defined, available snippets are: \
            \(available.lazy.map { "'\($0)'" } .joined(separator: ", "))
            """
        case .snippet(let undefined?, let available):
            """
            no such snippet '\(undefined)' exists in this package, available snippets are: \
            \(available.lazy.map { "'\($0)'" } .joined(separator: ", "))
            """

        case .slice(let undefined, let available):
            """
            snippet does not contain a slice named '\(undefined)', available slices: \
            \(available.lazy.map { "'\($0)'" } .joined(separator: ", "))
            """
        }
    }
}
