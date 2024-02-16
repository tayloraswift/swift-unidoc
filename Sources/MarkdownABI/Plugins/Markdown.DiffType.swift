extension Markdown
{
    /// Represents a diff highlight. This type is only defined in this module because it is
    /// language-agnostic and therefore would not belong in plugin modules.
    ///
    /// There are no special syntax highlighting classes associated with this type. Instead, we
    /// represent diffs in HTML using the semantic tags `del`, `ins`, and `mark`.
    @frozen public
    enum DiffType
    {
        case delete
        case insert
        case update
    }
}
