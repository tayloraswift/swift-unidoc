import ModuleGraphs
import System

extension Artifacts
{
    struct Sources
    {
        let module:ModuleStack
        let path:FilePath?

        /// Paths to all (non-excluded) markdown articles discovered in the
        /// relevant target’s sources directory.
        var articles:[FilePath]
        /// Indicates if the relevant target contains `.swift` sources only.
        /// This is false if the target contains at least one `.c`, `.h`,
        /// `.cpp`, `.hpp` file.
        var language:Language

        init(_ module:ModuleStack, path:FilePath? = nil)
        {
            self.module = module
            self.path = path

            self.articles = []
            self.language = .swift
        }
    }
}
extension Artifacts.Sources
{
    init(_ module:ModuleStack, root:__shared FilePath)
    {
        self.init(module,
            path: module.location.map { root / $0 } ?? root / "Sources" / "\(module.name)")
    }
}
