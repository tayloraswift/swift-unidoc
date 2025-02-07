import PackageGraphs
import PackageMetadata
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import SystemIO

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
        among modules:SSGC.ModuleGraph) throws -> [SSGC.Toolchain.SymbolDumpParameters]
    {
        var moduleCohabitants:[Symbol.Module: [SSGC.ModuleLayout]] = [:]
        for module:SSGC.ModuleLayout in modules.sinkLayout.cultures
        {
            let constituents:[SSGC.ModuleLayout] = try modules.constituents(of: module)
            for constituent:SSGC.ModuleLayout in constituents where
                constituent.module.type.hasSymbols
            {
                {
                    guard
                    let modules:[SSGC.ModuleLayout] = $0
                    else
                    {
                        $0 = constituents
                        return
                    }
                    //  This is a shared dependency, but we know it can be built alongside a
                    //  smaller set of cohabitating modules.
                    if  modules.count > constituents.count
                    {
                        $0 = constituents
                    }
                } (&moduleCohabitants[constituent.id])
            }
        }

        let moduleMaps:[Symbol.Module: FilePath] = moduleCohabitants.values.reduce(into: [:])
        {
            for layout:SSGC.ModuleLayout in $1
            {
                switch layout.module.language
                {
                case .cpp?: break
                case .c?:   break
                default:    continue
                }

                {
                    $0 = $0 ?? layout.modulemap ?? self.scratch.modulemap(
                        target: layout.module.name)
                } (&$0[layout.module.id])
            }
        }

        let modules:[SSGC.Toolchain.SymbolDumpParameters] = moduleCohabitants.map
        {
            $0.value.reduce(into: .init(
                moduleName: $0.key,
                includePaths: [self.scratch.modules]))
            {
                let id:Symbol.Module = $1.id
                if  id != $0.moduleName
                {
                    $0.allowedReexportedModules.append(id)
                }
                if  let file:FilePath = moduleMaps[id]
                {
                    $0.moduleMaps.append(file)
                }
            }
        }
        return modules.sorted { $0.moduleName < $1.moduleName }
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
    func local(project location:FilePath.Directory,
        using scratchName:FilePath.Component = ".build.ssgc",
        as type:SSGC.ProjectType = .package,
        flags:Flags = .init()) -> Self
    {
        /// The projects path could be absolute or relative. If it’s relative, we need to
        /// convert it to an absolute path.
        let location:FilePath.Directory = location.absolute()
        /// For a local project, the project name is the last component of the path, lowercased.
        guard
        let last:FilePath.Component = location.path.components.last
        else
        {
            fatalError("Can’t build a Swift package at file system root!")
        }

        let scratch:SSGC.PackageBuildDirectory = .init(configuration: .debug,
            location: location / scratchName)

        return .init(id: .unversioned(.init(last.string)),
            scratch: scratch,
            flags: flags,
            root: location,
            type: type)
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
        at refName:String,
        as type:SSGC.ProjectType = .package,
        in workspace:SSGC.Workspace,
        flags:Flags = .init(),
        clean:Bool = false) throws -> Self
    {
        let checkout:SSGC.Checkout = try .checkout(project: projectName,
            from: repository,
            at: refName,
            in: workspace,
            clean: clean)

        /// This is a far less-common use case than the local one, so we don’t support
        /// customizing the scratch directory name.
        let scratchName:FilePath.Component = ".build.ssgc"
        let scratch:SSGC.PackageBuildDirectory = .init(configuration: .debug,
            location: checkout.location / scratchName)

        let version:AnyVersion = .init(refName)
        let pin:SPM.DependencyPin = .init(identity: projectName,
            location: .remote(url: repository),
            revision: checkout.revision,
            version: version)

        return .init(id: .versioned(pin, ref: refName, date: checkout.date),
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
        with toolchain:SSGC.Toolchain,
        clean:Bool = true) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources)
    {
        switch self.type
        {
        case .package:
            try self.compileSwiftPM(updating: status,
                cache: cache,
                with: toolchain,
                clean: clean)

        case .book:
            try self.compileBook(updating: status,
                cache: cache,
                with: toolchain)
        }
    }
}

extension SSGC.PackageBuild
{
    @_spi(testable) public
    func compileBook(updating status:SSGC.StatusStream? = nil,
        cache _:FilePath.Directory,
        with toolchain:SSGC.Toolchain) throws -> (SymbolGraphMetadata, SSGC.BookSources)
    {
        switch self.id
        {
        case .unversioned(let package):
            print("Discovering sources for book '\(package)' (unversioned)")

        case .versioned(let pin, _, _):
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
            triple: toolchain.splash.triple,
            swift: toolchain.splash.swift,
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
        with toolchain:SSGC.Toolchain,
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

        case .versioned(let pin, _, _):
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")
        }

        let manifestVersions:[MinorVersion] = try self.listExtraManifests()
        var manifest:SPM.Manifest = try toolchain.manifest(package: self.root,
            json: artifacts / "\(self.id.package).package.json",
            leaf: true)

        //  SwiftPM will climb up the directory tree until it finds a `Package.swift` file.
        //  It is trying to be helpful, but it will cause problems so we need to diagnose if
        //  this is happening.
        switch FilePath.Directory.init(manifest.root.path)
        {
        case self.root: break
        case let other: throw SSGC.PackagePathError.init(computed: self.root, manifest: other)
        }

        print("""
            Resolving dependencies for '\(self.id.package)' \
            (swift-tools-version: \(manifest.format))
            """)

        let pins:[SPM.DependencyPin]
        do
        {
            pins = try toolchain.resolve(package: self.root)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_package_update(code, invocation)
        }

        try status?.send(.didResolveDependencies)

        do
        {
            try toolchain.build(package: self.root, using: self.scratch, flags: self.flags)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_build(code, invocation)
        }

        var packages:SSGC.PackageGraph = .init(platform: try toolchain.platform())

        for pin:SPM.DependencyPin in pins
        {
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try toolchain.manifest(
                package: self.scratch.location / "checkouts" / "\(pin.location.name)",
                json: artifacts / "\(pin.identity).package.json",
                leaf: false)

            packages.attach(manifest, as: pin.identity)
        }

        let standardLibrary:SSGC.StandardLibrary = .init(platform: packages.platform,
            version: toolchain.splash.swift.version.minor)

        let modules:SSGC.ModuleGraph = try packages.join(dependencies: pins,
            standardLibrary: standardLibrary,
            with: &manifest,
            as: self.id.package)

        //  Dump the standard library’s symbols, unless they’re already cached.
        let artifactsCached:FilePath.Directory = try toolchain.dump(
            standardLibrary: standardLibrary,
            cache: cache)
        for parameters:SSGC.Toolchain.SymbolDumpParameters in try self.modulesToDump(
            among: modules)
        {
            try toolchain.dump(parameters: parameters, options: .init(), to: artifacts)
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
            triple: toolchain.splash.triple,
            swift: toolchain.splash.swift,
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
