import SymbolGraphBuilder

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
        self.main(arguments: .init())
    }
}
