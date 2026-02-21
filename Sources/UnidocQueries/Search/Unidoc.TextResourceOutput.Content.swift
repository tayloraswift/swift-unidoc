import UnidocRecords

extension Unidoc.TextResourceOutput {
    @frozen public enum Content: Sendable {
        case inline(Unidoc.TextStorage)
        case length(Int)
    }
}
