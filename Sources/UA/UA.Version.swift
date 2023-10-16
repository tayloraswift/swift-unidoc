extension UA
{
    @frozen public
    struct Version:Equatable, Hashable, Sendable
    {
        public
        let major:Int
        public
        let minor:String?

        @inlinable public
        init(major:Int, minor:String? = nil)
        {
            self.major = major
            self.minor = minor
        }
    }
}
extension UA.Version:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.minor.map { "\(self.major).\($0)" } ?? "\(self.major)"
    }
}
