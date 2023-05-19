import PackageGraphs
import System

extension DocumentationArtifacts
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
extension DocumentationArtifacts.Culture:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.node.id
    }
}
extension DocumentationArtifacts.Culture
{
    @inlinable public
    init(parts:[FilePath], node:TargetNode) throws
    {
        if  parts.isEmpty
        {
            throw DocumentationArtifacts.CultureError.empty(node.id)
        }
        else
        {
            self.init(nonempty: parts, node: node)
        }
    }
}
