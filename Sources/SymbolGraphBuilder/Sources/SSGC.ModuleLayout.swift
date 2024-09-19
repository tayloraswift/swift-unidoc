import MarkdownABI
import SymbolGraphs
import Symbols
import System_

extension SSGC
{
    /// Stores information about the source files for a module.
    @dynamicMemberLookup
    @_spi(testable) public
    struct ModuleLayout
    {
        private(set)
        var resources:[LazyFile]
        /// Absolute paths to all (non-excluded) markdown articles discovered
        /// in the relevant target’s sources directory.
        private(set)
        var markdown:[LazyFile]
        /// Include paths for the module’s sources, usually appearing in C or C++ modules only.
        private(set)
        var include:[FilePath.Directory]

        private(set)
        var module:SymbolGraph.Module

        /// Absolute path to the module sources directory, if known.
        private
        var origin:Origin?

        private
        init(module:SymbolGraph.Module, origin:Origin? = nil)
        {
            self.resources = []
            self.markdown = []
            self.include = []
            self.module = module
            self.origin = origin
        }
    }
}
extension SSGC.ModuleLayout
{
    init(toolchain module:SymbolGraph.Module)
    {
        self.init(module: module)
    }

    init(
        package:borrowing SSGC.PackageRoot,
        bundle:borrowing FilePath.Directory,
        module:SymbolGraph.Module) throws
    {
        self.init(module: module)
        try self.scan(bundle: bundle, package: package)
    }

    init(
        exclude:borrowing [String],
        package:borrowing SSGC.PackageRoot,
        module:SymbolGraph.Module,
        count:[DefaultDirectory: Int]) throws
    {
        self.init(module: module)

        locations:
        if  let location:String = self.module.location
        {
            self.origin = .sources(package.location / location)
        }
        else
        {
            guard
            let directory:DefaultDirectory = .init(for: self.module.type)
            else
            {
                //  This is a binary module, which has no sources.
                break locations
            }

            let sources:FilePath.Directory = package.location / directory.name
            let nested:FilePath.Directory = sources / self.module.name

            if  nested.exists()
            {
                self.origin = .sources(nested)
            }
            else if case 1? = count[directory]
            {
                //  If there is only one module that should be in this directory, we can
                //  try scanning the directory itself.
                self.origin = .sources(sources)
            }
            else
            {
                //  Artifically synthesize the error we would have caught if we had tried to
                //  scan the nonexistent directory.
                throw FileError.opening(nested.path, .noSuchFileOrDirectory)
            }
        }

        self.include = try self.scan(exclude: exclude, package: package)
    }
}
extension SSGC.ModuleLayout
{
    subscript<T>(dynamicMember keyPath:KeyPath<SymbolGraph.Module, T>) -> T
    {
        self.module[keyPath: keyPath]
    }
}
extension SSGC.ModuleLayout
{
    private mutating
    func scan(bundle directory:FilePath.Directory, package root:SSGC.PackageRoot) throws
    {
        try directory.walk
        {
            if $0.directory.exists()
            {
                return true
            }

            switch $0.extension
            {
            case "tutorial"?, "md"?:
                let markdown:SSGC.LazyFile = .init(location: $0, root: root)
                self.markdown.append(markdown)

                //  Allow articles to embed their own source text.
                fallthrough

            default:
                //  Inside a *.docc directory, everything that is not markdown or a tutorial
                //  is a resource.
                let resource:SSGC.LazyFile = .init(location: $0, path: root.rebase($0))
                self.resources.append(resource)
                return false
            }
        }
    }

    private mutating
    func scan(exclude:[String], package root:SSGC.PackageRoot) throws -> [FilePath.Directory]
    {
        guard
        case .sources(let sources) = self.origin
        else
        {
            return []
        }

        let exclude:[FilePath] = exclude.map { sources / $0 }
        var bundles:[FilePath.Directory] = []
        var headers:Set<FilePath.Directory> = []

        defer
        {
            self.markdown.sort { $0.id < $1.id }
        }

        try sources.walk
        {
            let file:(path:FilePath, extension:String)

            switch $1.extension
            {
            case "md"?:
                //  It’s common to list markdown files under exclude paths.
                file.path = $0 / $1

                if  file.path.directory.exists()
                {
                    //  Someone has named a directory with a `.md` extension. Perhaps it
                    //  contains markdown files?
                    return true
                }
                else
                {
                    let supplement:SSGC.LazyFile = .init(location: $0 / $1, root: root)
                    self.markdown.append(supplement)
                    return false
                }

            case "docc"?, "unidoc"?:
                //  We will visit these later.
                file.path = $0 / $1
                bundles.append(file.path.directory)
                return false

            case let other?:
                file.path = $0 / $1
                file.extension = other

            case nil:
                file.path = $0 / $1
                return file.path.directory.exists()
            }

            //  TODO: might benefit from a better algorithm.
            for prefix:FilePath in exclude
            {
                if  file.path.starts(with: prefix)
                {
                    return false
                }
            }

            switch file.extension
            {
            case "swift":
                self.module.language |= .swift
                //  All extant versions of SwiftPM use the `main.swift` file name to
                //  indicate an executable module.
                if  $1.stem.lowercased() == "main"
                {
                    self.module.type = .executable
                }

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

            case "cc", "cpp", "cxx":
                self.module.language |= .cpp

            case "txt":
                //  The most common culprit is a `CMakeLists.txt`.
                //  It’s not worth warning about these.
                break

            case "s", "S":
                //  These sometimes show up in C modules. We ignore them.
                break

            default:
                print("Unknown file type: \(file.path)")
            }

            return true
        }

        for bundle:FilePath.Directory in bundles
        {
            try self.scan(bundle: bundle, package: root)
        }

        return self.module.type == .executable ? [] : headers.sorted
        {
            $0.path.string < $1.path.string
        }
    }
}
