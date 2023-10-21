extension AWS.S3
{
    @frozen public
    struct Bucket:Hashable, Sendable
    {
        public
        var region:AWS.Region
        public
        var name:String

        @inlinable public
        init(region:AWS.Region, name:String)
        {
            self.region = region
            self.name = name
        }
    }
}
