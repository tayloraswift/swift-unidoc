import System_
import TraceableErrors

extension SSGC
{
    struct SymbolDumpLoadingError:Error, Sendable
    {
        public
        let underlying:any Error
        public
        let path:FilePath

        public
        init(underlying:any Error, path:FilePath)
        {
            self.underlying = underlying
            self.path = path
        }
    }
}
extension SSGC.SymbolDumpLoadingError:Equatable
{
    static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path == rhs.path && lhs.underlying == rhs.underlying
    }
}
extension SSGC.SymbolDumpLoadingError:TraceableError
{
    var notes:[String]
    {
        ["while processing artifact '\(self.path)'"]
    }
}
