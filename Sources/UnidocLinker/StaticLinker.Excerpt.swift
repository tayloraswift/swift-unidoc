import Symbols
import MarkdownABI

extension StaticLinker
{
    public
    struct Excerpt:Equatable, Sendable
    {
        let symbol:ScalarSymbol
        let fragments:MarkdownBytecode?

        init(symbol:ScalarSymbol, fragments:MarkdownBytecode?)
        {
            self.symbol = symbol
            self.fragments = fragments
        }
    }
}
