import PackageGraphs
import PackageMetadata
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    public
    struct PackageBuild
    {
        /// What is being built.
        let id:ID

        let scratch:PackageBuildDirectory

        /// Additional flags to pass to the Swift compiler.
        var flags:Flags

        /// Where the package root directory is.
        let root:FilePath.Directory
        let type:ProjectType

        private
        init(id:ID,
            scratch:PackageBuildDirectory,
            flags:Flags,
            root:FilePath.Directory,
            type:ProjectType)
        {
            self.id = id
            self.scratch = scratch
            self.flags = flags
            self.root = root
            self.type = type
        }
    }
}
extension SSGC.PackageBuild
{
    private
    func listExtraManifests() throws -> [MinorVersion]
    {
        var versions:[MinorVersion] = []
        for file:Result<FilePath.Component, any Error> in self.root
        {
            let file:FilePath.Component = try file.get()
            let name:String = file.stem

            guard case "swift" = file.extension,
            let hyphen:String.Index = name.lastIndex(of: "-"),
            let suffix:MinorVersion = .init(name[name.index(after: hyphen)...]),
            case "Package@swift" = name[..<hyphen]
            else
            {
                continue
            }

            versions.append(suffix)
        }

        versions.sort()

        return versions
    }

    private
    func modulesToDump(
        among modules:SSGC.ModuleGraph) throws -> [(Symbol.Module, [FilePath.Directory])]
    {
        var modulesToDump:[Symbol.Module: [FilePath.Directory]] = [:]
        for module:SSGC.ModuleLayout in modules.sinkLayout.cultures
        {
            let constituents:[SSGC.ModuleLayout] = try modules.constituents(of: module)
            let include:[FilePath.Directory] = constituents.reduce(into: [self.scratch.include])
            {
                $0 += $1.include
            }
            for constituent:SSGC.ModuleLayout in constituents
            {
                //  The Swift compiler won’t generate these automatically, so we need to extract
                //  the symbols manually.
                switch constituent.language
                {
                case .c?:   break
                case .cpp?: break
                default:    continue
                }

                modulesToDump[constituent.id] = include
            }
        }

        return modulesToDump.sorted { $0.key < $1.key }
    }
}
extension SSGC.PackageBuild
{
    /// Creates a build setup by attaching a package located in a directory of the
    /// same name in the specified location.
    ///
    /// -   Parameters:
    ///     -   name:
    ///         The identifier of the package.
    ///     -   projects:
    ///         The location in which this function will search for a directory
    ///         named `"\(name)"`.
    ///     -   type:
    ///         The type of project to build.
    ///     -   flags:
    ///         Additional flags to pass to the Swift compiler.
    public static
    func local(
        project projectName:Symbol.Package,
        among projects:FilePath.Directory,
        using scratchName:FilePath.Component = ".build.ssgc",
        as type:SSGC.ProjectType = .package,
        flags:Flags = .init()) -> Self
    {
        let project:FilePath.Directory = projects / "\(projectName)"
        let scratch:SSGC.PackageBuildDirectory = .init(configuration: .debug,
            location: project / scratchName)

        if  project.path.isAbsolute
        {
            return .init(id: .unversioned(projectName),
                scratch: scratch,
                flags: flags,
                root: project,
                type: type)
        }
        else if
            let current:FilePath.Directory = .current()
        {
            return .init(id: .unversioned(projectName),
                scratch: scratch,
                flags: flags,
                root: .init(path: current.path.appending(project.path.components)),
                type: type)
        }
        else
        {
            fatalError("Couldn’t determine the current working directory.")
        }
    }

    /// Clones or pulls the specified package from a git repository, checking out
    /// the specified ref.
    ///
    /// -   Parameters:
    ///     -   name:
    ///         The identifier of the package to check out. This is *usually* the
    ///         same as the last path component of the remote URL.
    ///     -   repository:
    ///         The URL of the git repository to clone or pull from.
    ///     -   reference:
    ///         The git reference to check out. This string must match exactly, e.g. `v0.1.0`
    ///         is not equivalent to `0.1.0`.
    ///     -   type:
    ///         The type of project to build.
    ///     -   workspace:
    ///         The directory in which this function will create folders.
    public static
    func remote(project projectName:Symbol.Package,
        from repository:String,
        at reference:String,
        as type:SSGC.ProjectType = .package,
        in workspace:SSGC.Workspace,
        flags:Flags = .init(),
        clean:Bool = false) throws -> Self
    {
        let checkout:SSGC.Checkout = try .checkout(project: projectName,
            from: repository,
            at: reference,
            in: workspace,
            clean: clean)

        /// This is a far less-common use case than the local one, so we don’t support
        /// customizing the scratch directory name.
        let scratchName:FilePath.Component = ".build.ssgc"
        let scratch:SSGC.PackageBuildDirectory = .init(configuration: .debug,
            location: checkout.location / scratchName)

        let version:AnyVersion = .init(reference)
        let pin:SPM.DependencyPin = .init(identity: projectName,
            location: .remote(url: repository),
            revision: checkout.revision,
            version: version)

        return .init(id: .versioned(pin, reference: reference),
            scratch: scratch,
            flags: flags,
            root: checkout.location,
            type: type)
    }
}

extension SSGC.PackageBuild:SSGC.DocumentationBuild
{
    func compile(updating status:SSGC.StatusStream?,
        cache:FilePath.Directory,
        with swift:SSGC.Toolchain,
        clean:Bool = true) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources)
    {
        switch self.type
        {
        case .package:
            try self.compileSwiftPM(updating: status,
                cache: cache,
                with: swift,
                clean: clean)

        case .book:
            try self.compileBook(updating: status,
                cache: cache,
                with: swift)
        }
    }
}

extension SSGC.PackageBuild
{
    @_spi(testable) public
    func compileBook(updating status:SSGC.StatusStream? = nil,
        cache _:FilePath.Directory,
        with swift:SSGC.Toolchain) throws -> (SymbolGraphMetadata, SSGC.BookSources)
    {
        switch self.id
        {
        case .unversioned(let package):
            print("Discovering sources for book '\(package)' (unversioned)")

        case .versioned(let pin, _):
            print("Discovering sources for book '\(pin.identity)' at \(pin.state)")
        }

        //  This step is considered part of documentation building.
        let sources:SSGC.BookSources
        do
        {
            sources = try .init(scanning: self.root)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.scanning(error)
        }

        let metadata:SymbolGraphMetadata = .init(
            package: .init(
                scope: self.id.pin?.location.owner,
                name: self.id.package),
            commit: self.id.commit,
            triple: swift.triple,
            swift: swift.id,
            tools: nil,
            manifests: [],
            requirements: [],
            dependencies: [],
            products: [],
            display: "\(self.id.package)",
            root: sources.prefix)

        return (metadata, sources)
    }

    @_spi(testable) public
    func compileSwiftPM(updating status:SSGC.StatusStream? = nil,
        cache:FilePath.Directory,
        with swift:SSGC.Toolchain,
        clean:Bool = true) throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    {
        if  clean
        {
            try self.scratch.location.remove()
        }
        /// Note that the Swift compiler already uses a subdirectory named `artifacts`, so we
        /// name ours `ssgc` to avoid conflicts
        let artifacts:FilePath.Directory = self.scratch.location / "ssgc"
        try artifacts.create(clean: false)

        switch self.id
        {
        case .unversioned(let package):
            print("Dumping manifest for package '\(package)' (unversioned)")

        case .versioned(let pin, _):
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")
        }

        let manifestVersions:[MinorVersion] = try self.listExtraManifests()
        var manifest:SPM.Manifest = try swift.manifest(package: self.root,
            json: artifacts / "\(self.id.package).package.json",
            leaf: true)

        print("""
            Resolving dependencies for '\(self.id.package)' \
            (swift-tools-version: \(manifest.format))
            """)

        let pins:[SPM.DependencyPin]
        do
        {
            pins = try swift.resolve(package: self.root)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_package_update(code, invocation)
        }

        try status?.send(.didResolveDependencies)

        do
        {
            try swift.build(package: self.root,
                using: self.scratch,
                flags: self.flags.dumping(symbols: .default, to: artifacts))
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_build(code, invocation)
        }

        let platform:SymbolGraphMetadata.Platform = try swift.platform()
        var packages:SSGC.PackageGraph = .init(platform: platform)

        for pin:SPM.DependencyPin in pins
        {
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try swift.manifest(
                package: self.scratch.location / "checkouts" / "\(pin.location.name)",
                json: artifacts / "\(pin.identity).package.json",
                leaf: false)

            packages.attach(manifest, as: pin.identity)
        }

        let modules:SSGC.ModuleGraph = try packages.join(dependencies: pins,
            with: &manifest,
            as: self.id.package)

        //  Dump the standard library’s symbols, unless they’re already cached.
        let artifactsCached:FilePath.Directory = try swift.dump(
            standardLibrary: .init(platform: platform),
            options: .default,
            cache: cache)
        for (module, include):(Symbol.Module, [FilePath.Directory]) in try self.modulesToDump(
            among: modules)
        {
            try swift.dump(module: module, to: artifacts, options: .default, include: include)
        }

        //  This step is considered part of documentation building.
        var sources:SSGC.PackageSources = .init(scratch: self.scratch,
            symbols: [artifacts, artifactsCached],
            modules: modules)
        do
        {
            let snippetsDirectory:FilePath.Component
            if  let customDirectory:String = manifest.snippets
            {
                guard
                let customDirectory:FilePath.Component = .init(customDirectory)
                else
                {
                    throw SSGC.SnippetDirectoryError.invalid(customDirectory)
                }

                snippetsDirectory = customDirectory
            }
            else
            {
                snippetsDirectory = "Snippets"
            }

            try sources.detect(snippets: snippetsDirectory)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.scanning(error)
        }

        let metadata:SymbolGraphMetadata = .init(
            package: .init(
                scope: self.id.pin?.location.owner,
                name: self.id.package),
            commit: self.id.commit,
            triple: swift.triple,
            swift: swift.id,
            tools: manifest.format,
            manifests: manifestVersions,
            requirements: manifest.requirements,
            dependencies: try modules.dependenciesUsed(pins: pins),
            products: .init(viewing: modules.sink.products),
            display: manifest.name,
            root: sources.prefix)

        return (metadata, sources)
    }
}
