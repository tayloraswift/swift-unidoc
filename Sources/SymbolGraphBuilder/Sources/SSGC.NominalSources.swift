import MarkdownABI
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    /// Stores information about the source files for a module.
    struct NominalSources
    {
        private(set)
        var resources:[LazyFile]
        /// Absolute paths to all (non-excluded) markdown articles discovered
        /// in the relevant target’s sources directory.
        private(set)
        var markdown:[LazyFile]

        private(set)
        var module:SymbolGraph.Module
        /// Absolute path to the module sources directory, if known.
        private(set)
        var origin:Origin?

        private
        init(_ module:SymbolGraph.Module, origin:Origin? = nil)
        {
            self.resources = []
            self.markdown = []

            self.module = module
            self.origin = origin
        }
    }
}
extension SSGC.NominalSources
{
    init(toolchain module:consuming SymbolGraph.Module)
    {
        self.init(module)
    }

    init(exclude:borrowing [String],
        package:borrowing SSGC.PackageRoot,
        module:consuming SymbolGraph.Module,
        count:[DefaultDirectory: Int]) throws
    {
        self.init(module)

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

        try self.scan(exclude: exclude, package: package)
    }
}
extension SSGC.NominalSources
{
    private mutating
    func scan(exclude:[String], package root:SSGC.PackageRoot) throws
    {
        guard
        case .sources(let path) = self.origin
        else
        {
            return
        }

        let exclude:[FilePath] = exclude.map { path / $0 }

        defer
        {
            self.markdown.sort { $0.id < $1.id }
        }

        try path.walk
        {
            let file:(path:FilePath, extension:String)
            if  let `extension`:String = $1.extension
            {
                file.extension = `extension`
                file.path = $0 / $1
            }
            else
            {
                //  This is a directory, or some extensionless file we don’t care about
                return
            }

            if  file.extension == "docc"
            {
                //  This is a directory.
                return
            }
            if  file.extension == "md"
            {
                //  It’s common to list markdown files under exclude paths.
                let supplement:SSGC.LazyFile = .init(location: file.path, root: root)
                self.markdown.append(supplement)
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
            //  TODO: might also benefit from a better algorithm.
            var inDocC:Bool = false
            for component:FilePath.Component in $0.path.components
            {
                if  case "docc"? = component.extension
                {
                    inDocC = true
                    break
                }
            }

            if  inDocC
            {
                switch file.extension
                {
                case "tutorial":
                    let tutorial:SSGC.LazyFile = .init(location: file.path, root: root)
                    self.markdown.append(tutorial)

                default:
                    //  Inside a *.docc directory, everything that is not markdown or a tutorial
                    //  is a resource.
                    let resource:SSGC.LazyFile = .init(location: file.path,
                        path: root.rebase(file.path))

                    self.resources.append(resource)
                }
            }
            else
            {
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
                    break

                case "modulemap":
                    //  But modulemaps do.
                    fallthrough

                case "c":
                    self.module.language |= .c

                case "hpp", "hxx":
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
            }
        }
    }
}
