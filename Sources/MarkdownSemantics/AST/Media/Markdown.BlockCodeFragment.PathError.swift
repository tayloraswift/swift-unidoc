extension Markdown.BlockCodeFragment {
    enum PathError: Error {
        case directory(String)
        case format(String)
    }
}
extension Markdown.BlockCodeFragment.PathError: CustomStringConvertible {
    var description: String {
        switch self {
        case .directory(let path):
            """
            the legacy 'path' syntax requires the second path component to be 'Snippets', \
            found '\(path)'
            """

        case .format(let path):
            """
            the legacy 'path' syntax requires a path of the form 'Package/Snippets/Name', \
            found '\(path)'
            """
        }
    }
}
