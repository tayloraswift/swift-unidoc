import System

extension SPM
{
    class Resource<Content>
    {
        /// The amount of time it took to load this file from disk.
        private(set)
        var loadingTime:Duration
        private
        let location:FilePath

        init(location:FilePath)
        {
            self.loadingTime = .zero
            self.location = location
        }
    }
}
extension SPM.Resource
{
    private
    func time<T>(while body:() throws -> T) rethrows -> T
    {
        let start:ContinuousClock.Instant = .now
        defer
        {
            self.loadingTime += start.duration(to: .now)
        }
        print("Loading file \(self.location) ...")
        return try body()
    }
}
extension SPM.Resource<[UInt8]>
{
    public
    func read() throws -> [UInt8]
    {
        try self.time { try self.location.read() }
    }
}
extension SPM.Resource<String>
{
    public
    func read() throws -> String
    {
        try self.time { try self.location.read() }
    }

    public
    func utf8() throws -> [UInt8]
    {
        try self.time { try self.location.read() }
    }
}
