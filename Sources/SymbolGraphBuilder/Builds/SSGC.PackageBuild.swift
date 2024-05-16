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

        /// Where the package root directory is. There should be a `Package.swift`
        /// manifest at the top level of this directory.
        var root:FilePath
        /// Additional flags to pass to the Swift compiler.
        var flags:Flags

        private
        init(id:ID, root:FilePath, flags:Flags)
        {
            self.id = id
            self.root = root
            self.flags = flags
        }
    }
}
extension SSGC.PackageBuild
{
    func listExtraManifests() throws -> [MinorVersion]
    {
        var versions:[MinorVersion] = []
        for file:Result<FilePath.Component, any Error> in self.root.directory
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
    ///     -   package:
    ///         The identifier of the package.
    ///     -   packages:
    ///         The location in which this function will search for a directory
    ///         named `"\(package)"`.
    ///     -   flags:
    ///         Additional flags to pass to the Swift compiler.
    public static
    func local(package:Symbol.Package,
        among packages:FilePath,
        flags:Flags = .init()) -> Self
    {
        return .init(id: .unversioned(package), root: packages / "\(package)", flags: flags)
    }

    /// Clones or pulls the specified package from a git repository, checking out
    /// the specified ref.
    ///
    /// -   Parameters:
    ///     -   package:
    ///         The identifier of the package to check out. This is *usually* the
    ///         same as the last path component of the remote URL.
    ///     -   remote:
    ///         The URL of the git repository to clone or pull from.
    ///     -   reference:
    ///         The git reference to check out. This string must match exactly, e.g. `v0.1.0`
    ///         is not equivalent to `0.1.0`.
    ///     -   shared:
    ///         The directory in which this function will create folders.
    public static
    func remote(package:Symbol.Package,
        from repository:String,
        at reference:String,
        in workspace:SSGC.Workspace,
        flags:Flags = .init(),
        clean:Bool = false) throws -> Self
    {
        //  The directory layout looks something like:
        //
        //  myworkspace/
        //  ├── artifacts/
        //  └── checkouts/
        //      └── swift-example-package/
        //          ├── .git/
        //          ├── .build/
        //          ├── .build.unidoc/
        //          ├── Package.swift
        //          └── ...

        let clone:FilePath = workspace.checkouts / "\(package)"
        if  clean
        {
            try clone.directory.remove()
        }

        print("Pulling repository from remote: \(repository)")

        if  clone.directory.exists()
        {
            try SystemProcess.init(command: "git", "-C", "\(clone)", "fetch")()
        }
        else
        {
            try SystemProcess.init(command: "git", "-C", "\(workspace.checkouts)",
                "clone", repository, "\(package)", "--recurse-submodules")()
        }

        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "-c", "advice.detachedHead=false",
            "checkout", "-f", reference,
            "--recurse-submodules")()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "rev-list", "-n", "1", reference,
            stdout: writable)()

        //  Note: output contains trailing newline
        let stdout:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        if  let revision:SHA1 = .init(stdout.prefix(while: \.isHexDigit))
        {
            let version:AnyVersion = .init(reference)
            let pin:SPM.DependencyPin = .init(identity: package,
                location: .remote(url: repository),
                revision: revision,
                version: version)
            return .init(id: .versioned(pin, reference: reference), root: clone, flags: flags)
        }
        else
        {
            fatalError("unimplemented")
        }
    }
}
extension SSGC.PackageBuild:SSGC.DocumentationBuild
{
    mutating
    func compile(updating status:SSGC.StatusStream?,
        into artifacts:FilePath,
        with swift:SSGC.Toolchain) throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    {
        switch self.id
        {
        case    .unversioned(let package):
            print("Dumping manifest for package '\(package)' (unversioned)")

        case    .versioned(let pin, _),
                .upstream(let pin):
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

        /// The manifest root is always an absolute path, so we would rather use that.
        self.root = .init(manifest.root.path)

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
            scratch = try swift.build(package: self.root, flags: self.flags)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_build(code, invocation)
        }

        let platform:SymbolGraphMetadata.Platform = try swift.platform()

        var dependencies:[PackageNode] = []
        var include:[FilePath] = [scratch.include]

        //  Nominal dependencies mean we need to perform two passes.
        var packageContainingProduct:[String: Symbol.Package] = [:]
        var manifests:[SPM.Manifest] = []
            manifests.reserveCapacity(pins.count)

        for pin:SPM.DependencyPin in pins
        {
            let checkout:FilePath = scratch.path / "checkouts" / "\(pin.location.name)"

            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try swift.manifest(package: checkout,
                json: artifacts / "\(pin.identity).package.json",
                leaf: false)

            for product:SPM.Manifest.Product in manifest.products
            {
                packageContainingProduct[product.name] = pin.identity
            }

            manifests.append(manifest)
        }

        for (manifest, pin):(Int, SPM.DependencyPin) in zip(manifests.indices, pins)
        {
            try manifests[manifest].normalizeUnqualifiedDependencies(
                with: packageContainingProduct)

            let dependency:PackageNode = try .all(flattening: manifests[manifest],
                on: platform,
                as: pin.identity)

            let sources:SSGC.PackageSources = try .init(scanning: dependency)

            dependencies.append(dependency)
            include += sources.include
        }

        //  Now it is time to normalize the leaf manifest.
        for product:SPM.Manifest.Product in manifest.products
        {
            packageContainingProduct[product.name] = self.id.package
        }
        try manifest.normalizeUnqualifiedDependencies(with: packageContainingProduct)

        let sinkNode:PackageNode = try .all(flattening: manifest,
            on: platform,
            as: self.id.package)
        let flatNode:PackageNode = try sinkNode.flattened(dependencies: dependencies)

        let commit:SymbolGraphMetadata.Commit?
        if  case .versioned(let pin, let ref) = self.id
        {
            commit = .init(name: ref, sha1: pin.revision)
        }
        else
        {
            commit = nil
        }

        let dependenciesPinned:[SymbolGraphMetadata.Dependency] = try flatNode.pin(to: pins)
        let dependenciesUsed:Set<Symbol.Package> = flatNode.products.reduce(into: [])
        {
            guard
            case .library = $1.type
            else
            {
                return
            }
            for dependency:Symbol.Product in $1.dependencies
            {
                $0.insert(dependency.package)
            }
        }

        let metadata:SymbolGraphMetadata = .init(
            package: .init(
                scope: self.id.pin?.location.owner,
                name: self.id.package),
            commit: commit,
            triple: swift.triple,
            swift: swift.version,
            tools: manifest.format,
            manifests: manifestVersions,
            requirements: manifest.requirements,
            dependencies: dependenciesPinned.filter
            {
                dependenciesUsed.contains($0.package.name)
            },
            products: .init(viewing: flatNode.products),
            display: manifest.name,
            root: manifest.root)

        //  This step is considered part of documentation building.
        do
        {
            return (metadata, try .init(scanning: flatNode, include: include, scratch: scratch))
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.scanning(error)
        }
    }
}
