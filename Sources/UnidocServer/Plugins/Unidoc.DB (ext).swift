import HTTP
import MongoDB
import S3Client
import UnidocDB

extension Unidoc.DB
{
    func uplink(_ edition:Unidoc.Edition,
        from s3:AWS.S3.Client?) async throws -> Unidoc.UplinkStatus?
    {
        guard
        let s3:AWS.S3.Client
        else
        {
            return try await self.uplink(edition,
                loader: nil as AWS.S3.GraphLoader?)
        }

        return try await s3.connect
        {
            try await self.uplink(edition,
                loader: AWS.S3.GraphLoader.init(s3: $0))
        }
    }

    func authorize(package preloaded:Unidoc.PackageMetadata? = nil,
        loading id:Unidoc.Package,
        account:Unidoc.Account?,
        rights:Unidoc.UserRights,
        require minimum:Unidoc.PackageRights = .editor) async throws -> HTTP.ServerResponse?
    {
        guard
        case .enforced = self.policy.security,
        case .human = rights.level
        else
        {
            //  Only enforce ownership rules for humans.
            return nil
        }

        guard
        let account:Unidoc.Account
        else
        {
            return .unauthorized("You must be logged in to perform this operation!\n")
        }

        let package:Unidoc.PackageMetadata

        if  let preloaded:Unidoc.PackageMetadata
        {
            package = preloaded
        }
        else if
            let metadata:Unidoc.PackageMetadata = try await self.packages.find(id: id)
        {
            package = metadata
        }
        else
        {
            return .notFound("No such package\n")
        }

        let rights:Unidoc.PackageRights = .of(account: account,
            access: rights.access,
            rulers: package.rulers)

        if  rights >= minimum
        {
            return nil
        }

        return .forbidden("You are not authorized to edit this package!\n")
    }
}
