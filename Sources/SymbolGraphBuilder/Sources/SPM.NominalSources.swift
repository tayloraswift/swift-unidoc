import MarkdownABI
import SymbolGraphs
import Symbols
import System

extension SPM
{
    /// Stores information about the source files for a module.
    struct NominalSources
    {
        /// Absolute paths to all (non-excluded) markdown articles discovered
        /// in the relevant target’s sources directory.
        private(set)
        var articles:[Markdown.SourceFile]

        private(set)
        var module:SymbolGraph.Module
        /// Absolute path to the module sources directory, if known.
        private(set)
        var origin:Origin?

        private
        init(_ module:SymbolGraph.Module, origin:Origin? = nil)
        {
            self.module = module
            self.origin = origin

            self.articles = []
        }
    }
}
extension SPM.NominalSources
{
    init(include:inout [FilePath],
        exclude:borrowing [String],
        package:borrowing SPM.PackageRoot,
        module:consuming SymbolGraph.Module) throws
    {
        self.init(module)

        locations:
        if  let location:String = self.module.location
        {
            self.origin = .sources(package.path / location)
        }
        else
        {
            let directory:String
            switch self.module.type
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

            self.origin = .sources(package.path / directory / self.module.name)
        }

        try self.scan(include: &include, exclude: exclude, package: package)
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
    func scan(include:inout [FilePath], exclude:[String], package root:SPM.PackageRoot) throws
    {
        guard
        case .sources(let path) = self.origin
        else
        {
            return
        }

        let exclude:[FilePath] = exclude.map { path / $0 }
        var headers:Set<FilePath> = []

        defer
        {
            self.articles.sort { $0.id < $1.id }
            include += headers.sorted { $0.string < $1.string }
        }

        //  Precompute this once, since it’s used in the loop below.
        let module:Symbol.Module = self.module.id
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
                let supplement:Markdown.SourceFile = .init(location: file.path,
                    path: root.rebase(file.path),
                    in: module)

                self.articles.append(supplement)
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
                headers.update(with: $0)

            case "modulemap":
                //  But modulemaps do.
                headers.update(with: $0)
                fallthrough

            case "c":
                self.module.language |= .c

            case "hpp", "hxx":
                headers.update(with: $0)
                fallthrough

            case "cpp", "cxx":
                self.module.language |= .cpp

            case _:
                break
            }
        }
    }
}
