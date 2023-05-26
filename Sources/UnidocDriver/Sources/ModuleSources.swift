import ModuleGraphs
import System

/// Stores information about the source files for a module.
struct ModuleSources
{
    let module:ModuleInfo
    let path:FilePath?

    /// Indicates if the relevant target contains `.swift` sources only.
    /// This is false if the target contains at least one `.c`, `.h`,
    /// `.cpp`, `.hpp` file.
    private(set)
    var language:Language
    /// Paths to all (non-excluded) markdown articles discovered in the
    /// relevant target’s sources directory.
    private(set)
    var articles:[FilePath]
    /// Directories that contain header files. Empty if this is not a C
    /// or C++ module.
    private(set)
    var include:[FilePath]

    init(_ module:ModuleInfo, path:FilePath? = nil)
    {
        self.module = module
        self.path = path

        self.language = .swift
        self.articles = []
        self.include = []
    }
}
extension ModuleSources
{
    init(scanning module:__owned ModuleInfo,
        exclude:__shared [String],
        root:__shared FilePath) throws
    {
        try self.init(scanning: module, exclude: exclude,
            path: module.location.map { root / $0 } ?? root / "Sources" / "\(module.name)")
    }
    private
    init(scanning module:__owned ModuleInfo,
        exclude:__shared [String],
        path:__owned FilePath) throws
    {
        let exclude:Set<FilePath> = .init(exclude.lazy.map { path / $0 })
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
