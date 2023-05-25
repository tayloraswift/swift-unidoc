import PackageGraphs
import System

extension Artifacts
{
    struct Sources
    {
        let node:TargetNode
        let path:FilePath?

        /// Paths to all (non-excluded) markdown articles discovered in the
        /// relevant target’s sources directory.
        var articles:[FilePath]
        /// Indicates if the relevant target contains `.swift` sources only.
        /// This is false if the target contains at least one `.c`, `.h`,
        /// `.cpp`, `.hpp` file.
        var language:Language

        init(_ node:TargetNode, path:FilePath? = nil)
        {
            self.node = node
            self.path = path

            self.articles = []
            self.language = .swift
        }
    }
}
extension Artifacts.Sources
{
    init(_ node:TargetNode, root:__shared FilePath)
    {
        self.init(node,
            path: node.location.map { root / $0 } ?? root / "Sources" / "\(node.name)")
    }
}
