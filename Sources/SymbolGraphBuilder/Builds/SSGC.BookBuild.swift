import PackageMetadata
import SemanticVersions
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    public
    struct BookBuild
    {
        let id:ID
        /// Always an absolute path.
        let root:FilePath.Directory
    }
}
extension SSGC.BookBuild
{
    public static
    func local(package:Symbol.Package, among packages:FilePath.Directory) -> Self
    {
        let project:FilePath.Directory = packages / "\(package)"
        if  project.path.isAbsolute
        {
            return .init(id: .unversioned(package), root: project)
        }
        else if
            let current:FilePath.Directory = .current()
        {
            return .init(id: .unversioned(package),
                root: .init(path: current.path.appending(project.path.components)))
        }
        else
        {
            fatalError("Couldn’t determine the current working directory.")
        }
    }

    public static
    func remote(package:Symbol.Package,
        from repository:String,
        at reference:String,
        in workspace:SSGC.Workspace,
        clean:Bool = false) throws -> Self
    {
        let checkout:SSGC.Checkout = try .checkout(package: package,
            from: repository,
            at: reference,
            in: workspace,
            clean: clean)

        let version:AnyVersion = .init(reference)
        let pin:SPM.DependencyPin = .init(identity: package,
            location: .remote(url: repository),
            revision: checkout.revision,
            version: version)

        return .init(id: .versioned(pin, reference: reference), root: checkout.location)
    }
}
extension SSGC.BookBuild:SSGC.DocumentationBuild
{
    @_spi(testable) public mutating
    func compile(updating status:SSGC.StatusStream?,
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

        let commit:SymbolGraphMetadata.Commit?
        if  case .versioned(let pin, let ref) = self.id
        {
            commit = .init(name: ref, sha1: pin.revision)
        }
        else
        {
            commit = nil
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
            commit: commit,
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
}
