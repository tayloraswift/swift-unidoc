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

        /// Additional flags to pass to the Swift compiler.
        var flags:Flags

        /// Where the package root directory is.
        let root:FilePath.Directory
        let type:ProjectType

        private
        init(id:ID, flags:Flags, root:FilePath.Directory, type:ProjectType)
        {
            self.id = id
            self.flags = flags
            self.root = root
            self.type = type
        }
    }
}
extension SSGC.PackageBuild
{
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
    public static
    func local(project name:Symbol.Package,
        among projects:FilePath.Directory,
        as type:SSGC.ProjectType = .package,
        flags:Flags = .init()) -> Self
    {
        let project:FilePath.Directory = projects / "\(name)"
        if  project.path.isAbsolute
        {
            return .init(id: .unversioned(name),
                flags: flags,
                root: project,
                type: type)
        }
        else if
            let current:FilePath.Directory = .current()
        {
            return .init(id: .unversioned(name),
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
    func remote(project name:Symbol.Package,
        from repository:String,
        at reference:String,
        as type:SSGC.ProjectType = .package,
        in workspace:SSGC.Workspace,
        flags:Flags = .init(),
        clean:Bool = false) throws -> Self
    {
        let checkout:SSGC.Checkout = try .checkout(project: name,
            from: repository,
            at: reference,
            in: workspace,
            clean: clean)

        let version:AnyVersion = .init(reference)
        let pin:SPM.DependencyPin = .init(identity: name,
            location: .remote(url: repository),
            revision: checkout.revision,
            version: version)

        return .init(id: .versioned(pin, reference: reference),
            flags: flags,
            root: checkout.location,
            type: type)
    }
}

extension SSGC.PackageBuild:SSGC.DocumentationBuild
{
    func compile(updating status:SSGC.StatusStream?,
        into artifacts:FilePath.Directory,
        with swift:SSGC.Toolchain) throws -> (SymbolGraphMetadata,
        any SSGC.DocumentationSources)
    {
        switch self.type
        {
        case .package:  try self.compileSwiftPM(updating: status, into: artifacts, with: swift)
        case .book:     try self.compileBook(updating: status, into: artifacts, with: swift)
        }
    }
}

extension SSGC.PackageBuild
{
    @_spi(testable) public
    func compileBook(updating status:SSGC.StatusStream? = nil,
        into artifacts:FilePath.Directory,
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
            swift: swift.version,
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
        into artifacts:FilePath.Directory,
        with swift:SSGC.Toolchain) throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    {
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

        let scratch:SSGC.PackageBuildDirectory
        do
        {
            scratch = try swift.build(package: self.root, flags: self.flags.dumping(
                symbols: .default,
                to: artifacts))
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_build(code, invocation)
        }

        var packages:SSGC.PackageGraph = .init(platform: try swift.platform())

        //  Dump the standard library’s symbols
        let standardLibrary:SSGC.StandardLibrary = .init(platform: try swift.platform())
        try swift.dump(modules: standardLibrary.modules,
            to: artifacts)

        for pin:SPM.DependencyPin in pins
        {
            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try swift.manifest(
                package: scratch.location / "checkouts" / "\(pin.location.name)",
                json: artifacts / "\(pin.identity).package.json",
                leaf: false)

            packages.attach(manifest, as: pin.identity)
        }

        let modules:SSGC.ModuleGraph = try packages.join(dependencies: pins,
            with: &manifest,
            as: self.id.package)

        //  This step is considered part of documentation building.
        let sources:SSGC.PackageSources
        do
        {
            sources = try .init(scanning: modules, scratch: scratch)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.scanning(error)
        }

        //  try swift.dump(modules: sources.cultures.lazy.map(\.module),
        //      to: artifacts,
        //      include: include)

        let metadata:SymbolGraphMetadata = .init(
            package: .init(
                scope: self.id.pin?.location.owner,
                name: self.id.package),
            commit: self.id.commit,
            triple: swift.triple,
            swift: swift.version,
            tools: manifest.format,
            manifests: manifestVersions,
            requirements: manifest.requirements,
            dependencies: try modules.dependenciesUsed(pins: pins),
            products: .init(viewing: modules.package.products),
            display: manifest.name,
            root: sources.prefix)

        return (metadata, sources)
    }
}
