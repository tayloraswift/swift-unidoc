import HTTPServer
import LZ77
import S3
import S3Client

extension Unidoc.BuildArtifact
{
    mutating
    func export(from server:Unidoc.Server,
        _logsIncluded:Bool = true) async throws -> [Unidoc.BuildLogType]
    {
        var logs:[Unidoc.BuildLogType] = []

        let logsToExport:Int = self.logs.count
        if  logsToExport > 0 && _logsIncluded
        {
            if  let bucket:AWS.S3.Bucket = server.bucket.assets
            {
                logs.reserveCapacity(logsToExport)

                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await s3.connect
                {
                    for log:Unidoc.BuildLog in self.logs
                    {
                        let path:Unidoc.BuildLogPath = .init(package: self.package,
                            type: log.type)

                        try await $0.put(object: .init(
                                body: .binary(log.text.bytes),
                                type: .text(.plain, charset: .utf8),
                                encoding: .gzip),
                            using: .standard,
                            path: "\(path)")

                        logs.append(log.type)
                    }
                }
            }
            else
            {
                Log[.warning] = "No destination bucket configured for exporting build logs!"
                for log:Unidoc.BuildLog in self.logs
                {
                    print(String.init(decoding: try Gzip.extract(from: log.text.bytes),
                        as: Unicode.UTF8.self))
                }
            }
        }

        if  case .success(var snapshot) = self.outcome
        {
            defer
            {
                self.outcome = .success(snapshot)
            }
            if  let bucket:AWS.S3.Bucket = server.bucket.graphs
            {
                let s3:AWS.S3.Client = .init(threads: server.context.threads,
                    niossl: server.context.niossl,
                    bucket: bucket)

                try await snapshot.moveSymbolGraph(to: s3)
            }
        }

        return logs
    }
}
