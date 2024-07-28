import SymbolGraphs

extension SSGC
{
    struct DocumentationBuildProfiler
    {
        var loadingSymbols:Duration
        var loadingSources:Duration
        var compiling:Duration
        var linking:Duration

        private
        var clock:ContinuousClock

        init()
        {
            self.loadingSymbols = .zero
            self.loadingSources = .zero
            self.compiling = .zero
            self.linking = .zero

            self.clock = .init()
        }
    }
}
extension SSGC.DocumentationBuildProfiler
{
    mutating
    func measure<T>(_ category:WritableKeyPath<Self, Duration>,
        while body:() throws -> T) rethrows -> T
    {
        let started:ContinuousClock.Instant = self.clock.now
        defer
        {
            self[keyPath: category] += started.duration(to: self.clock.now)
        }
        return try body()
    }

    mutating
    func measure<T>(_ category:WritableKeyPath<Self, Duration>,
        while body:() async throws -> T) async rethrows -> T
    {
        let started:ContinuousClock.Instant = self.clock.now
        defer
        {
            self[keyPath: category] += started.duration(to: self.clock.now)
        }
        return try await body()
    }
}
