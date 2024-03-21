extension Swiftinit.DB
{
    @frozen public
    struct Policy
    {
        public
        var apiLimitInterval:Duration
        public
        var apiLimitPerReset:Int

        @inlinable
        init()
        {
            self.apiLimitInterval = .seconds(15)
            self.apiLimitPerReset = 1
        }
    }
}
