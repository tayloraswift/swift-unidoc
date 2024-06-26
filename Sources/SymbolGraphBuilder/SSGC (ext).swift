import ArgumentParsing
import SymbolGraphs

extension SSGC
{
    @MainActor public static
    func main(arguments:consuming CommandLine.Arguments) -> Int32
    {
        do
        {
            var main:Main = .init()
            try main.parse(arguments: arguments)
            try main.launch()
            return 0
        }
        catch let error
        {
            print("Error: \(error)")
            return 1
        }
    }
}
