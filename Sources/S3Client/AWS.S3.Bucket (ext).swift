extension AWS.S3.Bucket {
    @inlinable var domain: String { "\(self.name).s3.\(self.region).amazonaws.com" }
}
