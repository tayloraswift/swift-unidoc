import Symbols
import UCF

extension UCF
{
    @frozen public
    struct ArticleScope
    {
        public
        let namespace:Symbol.Module?

        @inlinable public
        init(namespace:Symbol.Module?)
        {
            self.namespace = namespace
        }
    }
}
