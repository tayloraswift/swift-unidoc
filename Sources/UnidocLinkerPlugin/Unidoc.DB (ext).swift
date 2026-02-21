import S3
import S3Client
import UnidocLinker

extension Unidoc.DB {
    func uplink(_ id: Unidoc.Edition, s3: AWS.S3.Client?) async throws -> Unidoc.UplinkStatus? {
        guard
        let s3: AWS.S3.Client else {
            return try await self.uplink(id, loader: .inline)
        }

        return try await s3.connect {
            try await self.uplink(id, loader: AWS.S3.GraphLoader.init(s3: $0))
        }
    }

    private func uplink(
        _ id: Unidoc.Edition,
        loader: some Unidoc.GraphLoader
    ) async throws -> Unidoc.UplinkStatus? {
        guard
        let package: Unidoc.PackageMetadata = try await self.packages.find(id: id.package),
        let stored: Unidoc.Snapshot = try await self.snapshots.find(id: id) else {
            return nil
        }

        return try await self.uplink(
            snapshot: stored,
            package: package,
            linker: .dynamic,
            loader: loader
        )
    }
}
