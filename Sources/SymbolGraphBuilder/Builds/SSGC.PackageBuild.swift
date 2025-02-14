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
    public
    static func local(project location:FilePath.Directory,
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
    public
    static func remote(project projectName:Symbol.Package,
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
        with toolchain:SSGC.Toolchain,
        clean:Bool = true) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources)
    {
        switch self.type
        {
        case .package:
            try self.compileSwiftPM(updating: status, with: toolchain, clean: clean)

        case .book:
            try self.compileBook(updating: status, with: toolchain)
        }
    }
}

extension SSGC.PackageBuild
{
    @_spi(testable) public
    func compileBook(updating status:SSGC.StatusStream? = nil,
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
        let modules:SSGC.ModuleGraph
        do
        {
            modules = try .book(name: self.id.package, root: self.root)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.scanning(error)
        }

        let sources:SSGC.BookSources = .init(modules: modules,
            root: .init(self.root.path.string))

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
        let manifest:SPM.Manifest = try toolchain.manifest(package: self.root,
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

        var packageGraph:SSGC.PackageGraph = .init(platform: try toolchain.platform())

        for pin:SPM.DependencyPin in pins
        {
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try toolchain.manifest(
                package: self.scratch.location / "checkouts" / "\(pin.location.name)",
                json: artifacts / "\(pin.identity).package.json",
                leaf: false)

            packageGraph.attach(manifest, as: pin.identity)
        }

        let packageNodes:([PackageNode], sink:PackageNode) = try packageGraph.join(
            dependencies: pins,
            sinkManifest: manifest,
            sinkPackage: self.id.package)

        let stdlib:SSGC.ModuleGraph = .stdlib(
            platform: packageGraph.platform,
            version: toolchain.splash.swift.version.minor)

        let modules:SSGC.ModuleGraph = try .package(sink: packageNodes.sink,
            dependencies: packageNodes.0,
            substrate: stdlib.cultures.map(\.layout),
            sparseEdges: packageGraph.sparseEdges)

        //  Dump the standard library’s symbols, unless they’re already cached.
        let symbolsCached:FilePath.Directory = try toolchain.dump(stdlib: stdlib,
            cache: artifacts)

        let symbols:FilePath.Directory = artifacts / "symbols"
        try symbols.create(clean: false)

        try toolchain.dump(scratch: self.scratch, modules: modules, to: symbols)

        //  This step is considered part of documentation building.
        let sources:SSGC.PackageSources = .init(
            modules: modules,
            symbols: [symbols, symbolsCached],
            scratch: self.scratch,
            root: packageNodes.sink.root)

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
            dependencies: try modules.dependenciesUsed(among: pins),
            products: .init(viewing: modules.products),
            display: manifest.name,
            root: sources.prefix)

        return (metadata, sources)
    }
}
