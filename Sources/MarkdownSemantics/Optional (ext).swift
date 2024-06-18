extension Optional<Markdown.SemanticMetadata.Option<Bool>>
{
    /// Assigns the operand to self if self is nil and the operand has
    /// ``Markdown.SemanticMetadata.OptionScope/global`` scope.
    @inlinable static
    func ?= (self:inout Self, option:Self)
    {
        guard case .global? = option?.scope
        else
        {
            return
        }

        self = self ?? option
    }
}
