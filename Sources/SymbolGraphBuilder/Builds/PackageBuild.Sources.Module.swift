import SymbolGraphs
import System

extension PackageBuild.Sources
{
    /// Stores information about the source files for a module.
    struct Module
    {
        let module:SymbolGraph.Module
        /// Absolute path to the module sources directory, if known.
        let path:FilePath?

        /// Indicates if the relevant target contains `.swift` sources only.
        /// This is false if the target contains at least one `.c`, `.h`,
        /// `.cpp`, `.hpp` file.
        private(set)
        var language:PackageBuild.SourceLanguage
        /// Absolute paths to all (non-excluded) markdown articles discovered
        /// in the relevant target’s sources directory.
        private(set)
        var articles:[FilePath]
        /// Directories that contain header files. Empty if this is not a C
        /// or C++ module.
        private(set)
        var include:[FilePath]

        private
        init(_ module:SymbolGraph.Module, path:FilePath?)
        {
            self.module = module
            self.path = path

            self.language = .swift
            self.articles = []
            self.include = []
        }
    }
}
extension PackageBuild.Sources.Module
{
    init(_ module:SymbolGraph.Module)
    {
        self.init(module, path: nil)
    }

    init(scanning module:SymbolGraph.Module,
        exclude:borrowing [String],
        root:borrowing FilePath) throws
    {
        try self.init(scanning: module, exclude: exclude,
            path: module.location.map { root / $0 } ?? root / "Sources" / "\(module.name)")
    }

    private
    init(scanning module:SymbolGraph.Module,
        exclude:borrowing [String],
        path:FilePath) throws
    {
        let exclude:Set<FilePath> = exclude.reduce(into: []) { $0.insert(path / $1) }
        var include:Set<FilePath> = []

        self.init(module, path: path)
        defer
        {
            self.include = include.sorted   { $0.string < $1.string }
            self.articles.sort              { $0.string < $1.string }
        }
        try path.directory.walk
        {
            let file:(path:FilePath, extension:String)

            if  let `extension`:String = $1.extension
            {
                file.extension = `extension`
                file.path = $0 / $1
            }
            else
            {
                //  directory, or some extensionless file we don’t care about
                return
            }

            switch (file.extension, excluded: exclude.contains(file.path))
            {
            case    ("md",  excluded: _):
                //  It’s common to list markdown files under exclude paths.
                self.articles.append(file.path)

            case    ("h",   excluded: false):
                include.update(with: $0)
                fallthrough

            case    ("c",   excluded: false):
                self.language |= .c

            case    ("hpp", excluded: false),
                    ("hxx", excluded: false):
                include.update(with: $0)
                fallthrough

            case    ("cpp", excluded: false),
                    ("cxx", excluded: false):
                self.language |= .cpp

            case _:
                break
            }
        }
    }
}
