import SymbolGraphBuilder
import System

#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Darwin)
@preconcurrency import Darwin
#endif

@MainActor
@main
extension SSGC
{
    static
    func main()
    {
        setlinebuf(stdout)
        SystemProcess.exit(with: Self.main(arguments: .init()))
    }
}
