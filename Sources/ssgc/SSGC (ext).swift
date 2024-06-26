import SymbolGraphBuilder
import System

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
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
