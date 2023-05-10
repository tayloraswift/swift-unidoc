import Repositories
import System

extension Driver
{
    @frozen public
    struct Culture:Equatable
    {
        public
        let module:ModuleIdentifier
        public
        let parts:[FilePath]

        @inlinable internal
        init(module:ModuleIdentifier, nonempty:[FilePath])
        {
            self.module = module
            self.parts = nonempty
        }
    }
}
extension Driver.Culture
{
    @inlinable public
    init(module:ModuleIdentifier, parts:[FilePath]) throws
    {
        if  parts.isEmpty
        {
            throw Driver.CultureError.empty(module)
        }
        else
        {
            self.init(module: module, nonempty: parts)
        }
    }
}
