import ArgumentParsing
import SymbolGraphs
import System

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
            SystemProcess.exit(with: 1)
        }
    }
}
