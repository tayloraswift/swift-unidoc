import PackageGraphs
import System

extension Driver
{
    @frozen public
    struct Culture
    {
        public
        let parts:[FilePath]
        public
        let node:TargetNode

        @inlinable internal
        init(nonempty:[FilePath], node:TargetNode)
        {
            self.parts = nonempty
            self.node = node
        }
    }
}
extension Driver.Culture:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.node.id
    }
}
extension Driver.Culture
{
    @inlinable public
    init(parts:[FilePath], node:TargetNode) throws
    {
        if  parts.isEmpty
        {
            throw Driver.CultureError.empty(node.id)
        }
        else
        {
            self.init(nonempty: parts, node: node)
        }
    }
}
