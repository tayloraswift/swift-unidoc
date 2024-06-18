extension Markdown.SemanticMetadata
{
    @frozen public
    struct Options
    {
        public
        var automaticSeeAlso:Option<Bool>?
        public
        var automaticTitleHeading:Option<Bool>?

        @inlinable
        init()
        {
            self.automaticSeeAlso = nil
            self.automaticTitleHeading = nil
        }
    }
}
extension Markdown.SemanticMetadata.Options:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(Never, Bool)...)
    {
        self.init()
    }
}
extension Markdown.SemanticMetadata.Options
{
    /// Copies the values of the options from the other instance to self, if and only if the
    /// option has not already been set, and the `other` option has
    /// ``Markdown.SemanticMetadata.OptionScope/global`` scope.
    @inlinable public mutating
    func propogate(from other:Self)
    {
        self.automaticSeeAlso ?= other.automaticSeeAlso
        self.automaticTitleHeading ?= other.automaticTitleHeading
    }
}
