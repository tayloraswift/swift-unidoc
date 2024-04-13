#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#else
#error("unsupported platform")
#endif

import ArgumentParsing
import SymbolGraphs

extension SSGC
{
    @MainActor public static
    func main(arguments:consuming CommandLine.Arguments)
    {
        do
        {
            var main:Main = .init()
            try main.parse(arguments: arguments)
            try main.launch()
            return
        }
        catch let error
        {
            print("Error: \(error)")
            exit(1)
        }
    }
}
