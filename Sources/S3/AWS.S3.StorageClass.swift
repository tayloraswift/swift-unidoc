extension AWS.S3
{
    @frozen public
    enum StorageClass:String, Hashable, Sendable
    {
        /// Deprecated, and actually costs more than ``standard``. There is never a reason
        /// to use this.
        case reducedRedundancy = "REDUCED_REDUNDANCY"

        /// The standard storage class.
        case standard = "STANDARD"
        /// The standard infrequent access storage class.
        case standardIA = "STANDARD_IA"
        /// The single-zone infrequent access storage class. It costs about 20 percent less
        /// than ``standardIA``.
        case oneZoneIA = "ONEZONE_IA"
        case glacier = "GLACIER"
        case glacierIR = "GLACIER_IR"
        case deepArchive = "DEEP_ARCHIVE"
        case intelligentTiering = "INTELLIGENT_TIERING"
        case outposts = "OUTPOSTS"
        case snow = "SNOW"
    }
}
extension AWS.S3.StorageClass:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
