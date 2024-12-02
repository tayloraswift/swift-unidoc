import ArgumentParser
import S3
import UnidocServer

extension Unidoc
{
    @frozen public
    struct BucketOptions:ParsableArguments
    {
        @Option(
            name: [.customLong("s3-assets")],
            help: """
                The name of an S3 bucket for temporary storage
                """)
        public
        var assets:String?

        @Option(
            name: [.customLong("s3-bucket")],
            help: """
                The name of an S3 bucket for persistent storage
                """)
        public
        var bucket:String?

        @Option(
            name: [.customLong("s3-region")],
            help: """
                The AWS region the S3 buckets reside in
                """)
        public
        var region:AWS.Region = .us_east_1

        public
        init() {}
    }
}
extension Unidoc.BucketOptions
{
    public
    var buckets:Unidoc.Buckets
    {
        .init(
            assets: self.assets.map { .init(region: .us_east_1, name: $0) },
            graphs: self.bucket.map { .init(region: .us_east_1, name: $0) })
    }
}
