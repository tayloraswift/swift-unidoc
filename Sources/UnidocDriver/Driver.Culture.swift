import PackageGraphs
import System

extension Driver
{
    @frozen public
    struct Culture:Identifiable, Equatable
    {
        public
        let id:ModuleIdentifier
        public
        let parts:[FilePath]

        @inlinable internal
        init(id module:ModuleIdentifier, nonempty:[FilePath])
        {
            self.id = module
            self.parts = nonempty
        }
    }
}
extension Driver.Culture
{
    @inlinable public
    init(id module:ModuleIdentifier, parts:[FilePath]) throws
    {
        if  parts.isEmpty
        {
            throw Driver.CultureError.empty(module)
        }
        else
        {
            self.init(id: module, nonempty: parts)
        }
    }
}
