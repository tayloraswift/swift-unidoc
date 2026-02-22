import SymbolGraphs

extension SymbolGraphMetadata.Commit {
    static func parenthesizedSwiftRelease(_ string: Substring) -> Self? {
        guard string.startIndex < string.endIndex else {
            return nil
        }

        let bounds: (String.Index, String.Index) = (
            string.index(after: string.startIndex),
            string.index(before: string.endIndex)
        )

        guard bounds.0 < bounds.1,
        case ("(", ")") = (string[string.startIndex], string[bounds.1]) else {
            return nil
        }

        let content: Substring = string[bounds.0 ..< bounds.1]

        guard
        let i: String.Index = content.firstIndex(of: "-"),
        let j: String.Index = content.lastIndex(of: "-"),
        case ("swift", "-RELEASE") = (content[..<i], content[j...]) else {
            return nil
        }

        return .init(name: String.init(content), sha1: nil)
    }
}
