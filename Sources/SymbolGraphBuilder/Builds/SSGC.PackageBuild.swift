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
        /// Where to emit documentation artifacts to.
        let artifacts:ArtifactsDirectory

        /// Where the package root directory is. There should be a `Package.swift`
        /// manifest at the top level of this directory.
        var root:FilePath

        init(id:ID, artifacts:ArtifactsDirectory, root:FilePath)
        {
            self.id = id
            self.artifacts = artifacts
            self.root = root
        }
    }
}
extension SSGC.PackageBuild
{
    /// Always returns ``Configuration/debug``.
    var configuration:Configuration { .debug }
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
    ///     -   shared:
    ///         The directory in which this function will create a location to
    ///         dump build artifacts to.
    public static
    func local(package:Symbol.Package,
        from packages:FilePath,
        in shared:SSGC.Workspace,
        clean:Bool = false) async throws -> Self
    {
        let container:SSGC.Workspace = try await shared.create("\(package)", clean: clean)

        return .init(id: .unversioned(package),
            // https://github.com/apple/swift/issues/71602
            artifacts: try await container.create("artifacts", as: ArtifactsDirectory.self),
            root: packages / "\(package)")
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
    ///     -   refname:
    ///         The ref to check out. This string must match exactly, e.g. `v0.1.0`
    ///         is not equivalent to `0.1.0`.
    ///     -   shared:
    ///         The directory in which this function will create folders.
    public static
    func remote(package:Symbol.Package,
        from repository:String,
        at refname:String,
        in shared:SSGC.Workspace,
        clean:Set<Clean> = []) async throws -> Self
    {
        let version:AnyVersion = .init(refname)

        //  The directory layout looks something like:
        //
        //  myworkspace/
        //  └── username.swift-example-package/
        //      ├── artifacts@v1.0.0/
        //      │   └── ...
        //      ├── artifacts@v1.1.0/
        //      │   └── ...
        //      └── checkouts/
        //          └── swift-example-package/
        //              ├── .git/
        //              ├── .build/
        //              ├── .build.unidoc/
        //              ├── Package.swift
        //              └── ...

        let container:SSGC.Workspace = try await shared.create("\(package)")
        let checkouts:SSGC.CheckoutDirectory = try await container.create("checkouts",
            clean: clean.contains(.checkouts),
            as: SSGC.CheckoutDirectory.self) // https://github.com/apple/swift/issues/71602
        let artifacts:ArtifactsDirectory = try await container.create("artifacts@\(refname)",
            clean: clean.contains(.artifacts),
            as: ArtifactsDirectory.self)    // ditto

        let cloned:FilePath = checkouts.path / "\(package)"

        print("Pulling repository from remote: \(repository)")

        if  cloned.directory.exists()
        {
            try await SystemProcess.init(command: "git", "-C", "\(cloned)", "fetch")()
        }
        else
        {
            try await SystemProcess.init(command: "git", "-C", "\(checkouts)",
                "clone", repository, "\(package)", "--recurse-submodules", "--quiet")()
        }

        try await SystemProcess.init(command: "git", "-C", "\(cloned)",
            "-c", "advice.detachedHead=false",
            "checkout", "-f", refname,
            "--recurse-submodules")()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", "\(cloned)",
            "rev-list", "-n", "1", refname,
            stdout: writable)()

        //  Note: output contains trailing newline
        let stdout:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        if  let revision:SHA1 = .init(stdout.prefix(while: \.isHexDigit))
        {
            let pin:SPM.DependencyPin = .init(identity: package,
                location: .remote(url: repository),
                revision: revision,
                version: version)
            return .init(id: .versioned(pin, refname: refname),
                artifacts: artifacts,
                root: cloned)
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
    func compile(
        with swift:SSGC.Toolchain,
        logs:inout Logs) async throws -> (SymbolGraphMetadata, SSGC.PackageSources)
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
        var manifest:SPM.Manifest = try await swift.manifest(package: self.root,
            json: self.artifacts.path / "\(self.id.package).package.json",
            leaf: true)

        print("""
            Resolving dependencies for '\(self.id.package)' \
            (swift-tools-version: \(manifest.format))
            """)

        /// The manifest root is always an absolute path, so we would rather use that.
        self.root = .init(manifest.root.path)

        let log:(resolution:FilePath, build:FilePath) =
        (
            self.artifacts.path / "resolution.log",
            self.artifacts.path / "build.log"
        )

        let pins:[SPM.DependencyPin]

        do
        {
            pins = try await swift.resolve(package: self.root, log: log.resolution)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            logs.swiftPackageResolution = try? log.resolution.read()
            throw SSGC.PackageBuildError.swift_package_update(code, invocation)
        }

        let scratch:SSGC.PackageBuildDirectory
        do
        {
            scratch = try await swift.build(package: self.root,
                log: log.build)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            logs.swiftPackageBuild = try? log.build.read()
            throw SSGC.PackageBuildError.swift_build(code, invocation)
        }

        let platform:SymbolGraphMetadata.Platform = try swift.platform()

        var dependencies:[PackageNode] = []
        var include:[FilePath] = [ scratch.path / "\(self.configuration)" ]

        //  Nominal dependencies mean we need to perform two passes.
        var packageContainingProduct:[String: Symbol.Package] = [:]
        var manifests:[SPM.Manifest] = []
            manifests.reserveCapacity(pins.count)

        for pin:SPM.DependencyPin in pins
        {
            let checkout:FilePath = scratch.path / "checkouts" / "\(pin.location.name)"

            print("Dumping manifest for package '\(pin.identity)' at \(pin.state)")

            let manifest:SPM.Manifest = try await swift.manifest(package: checkout,
                json: self.artifacts.path / "\(pin.identity).package.json",
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

        return (metadata, try .init(scanning: flatNode, include: include))
    }
}
