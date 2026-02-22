import HTTP
import MongoDB
import S3Client
import UnidocDB

extension Unidoc.DB {
    func authorize(
        package preloaded: Unidoc.PackageMetadata? = nil,
        loading id: Unidoc.Package,
        account: Unidoc.Account?,
        rights: Unidoc.UserRights,
        require minimum: Unidoc.PackageRights = .editor
    ) async throws -> HTTP.ServerResponse? {
        guard
        case .enforced = self.settings.access,
        case .human = rights.level else {
            //  Only enforce ownership rules for humans.
            return nil
        }

        guard
        let account: Unidoc.Account else {
            return .unauthorized("You must be logged in to perform this operation!\n")
        }

        let package: Unidoc.PackageMetadata

        if  let preloaded: Unidoc.PackageMetadata {
            package = preloaded
        } else if
            let metadata: Unidoc.PackageMetadata = try await self.packages.find(id: id) {
            package = metadata
        } else {
            return .notFound("No such package\n")
        }

        let rights: Unidoc.PackageRights = .of(
            account: account,
            access: rights.access,
            rulers: package.rulers
        )

        if  rights >= minimum {
            return nil
        }

        return .forbidden("You are not authorized to edit this package!\n")
    }
}
