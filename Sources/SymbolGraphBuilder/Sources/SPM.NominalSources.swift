import SymbolGraphs
import Symbols
import System

extension SPM
{
    /// Stores information about the source files for a module.
    struct NominalSources
    {
        var module:SymbolGraph.Module
        /// Absolute path to the module sources directory, if known.
        private(set)
        var origin:Origin?

        /// Absolute paths to all (non-excluded) markdown articles discovered
        /// in the relevant target’s sources directory.
        private(set)
        var articles:[FilePath]
        /// Directories that contain header files. Empty if this is not a C
        /// or C++ module.
        private(set)
        var include:[FilePath]

        private
        init(_ module:SymbolGraph.Module, origin:Origin? = nil)
        {
            self.module = module
            self.origin = origin

            self.articles = []
            self.include = []
        }
    }
}
extension SPM.NominalSources
{
    init(scanning module:SymbolGraph.Module,
        exclude:borrowing [String],
        root:borrowing FilePath) throws
    {
        self.init(module)

        locations:
        if  let location:String = module.location
        {
            self.origin = .sources(root / location)
        }
        else
        {
            let directory:String
            switch module.type
            {
            case .binary:       break locations
            case .executable:   directory = "Sources"
            case .regular:      directory = "Sources"
            case .macro:        directory = "Sources"
            case .plugin:       directory = "Plugins"
            case .snippet:      directory = "Snippets"
            case .system:       directory = "Sources"
            case .test:         directory = "Tests"
            }

            self.origin = .sources(root / directory / module.name)
        }

        try self.scan(excluding: exclude)
    }

    static
    func toolchain(module name:String, dependencies:Int...) -> Self
    {
        .init(.init(name: name,
                type: .binary,
                dependencies: .init(modules: dependencies)),
            origin: .toolchain)
    }
}
extension SPM.NominalSources
{
    private mutating
    func scan(excluding exclude:[String]) throws
    {
        guard
        case .sources(let path) = self.origin
        else
        {
            return
        }

        let exclude:[FilePath] = exclude.map { path / $0 }
        var include:Set<FilePath> = []

        defer
        {
            self.articles.sort              { $0.string < $1.string }
            self.include = include.sorted   { $0.string < $1.string }
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

            guard file.extension != "md"
            else
            {
                //  It’s common to list markdown files under exclude paths.
                self.articles.append(file.path)
                return
            }

            //  TODO: might benefit from a better algorithm.
            for prefix:FilePath in exclude
            {
                if  file.path.starts(with: prefix)
                {
                    return
                }
            }

            switch file.extension
            {
            case "swift":
                self.module.language |= .swift

            case "h":
                //  Header files don’t indicate a C or C++ module on their own.
                include.update(with: $0)

            case "modulemap":
                //  But modulemaps do.
                include.update(with: $0)
                fallthrough

            case "c":
                self.module.language |= .c

            case "hpp", "hxx":
                include.update(with: $0)
                fallthrough

            case "cpp", "cxx":
                self.module.language |= .cpp

            case _:
                break
            }
        }
    }
}
