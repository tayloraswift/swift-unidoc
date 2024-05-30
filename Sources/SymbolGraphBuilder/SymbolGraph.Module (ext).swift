import SymbolGraphs

extension SymbolGraph.Module
{
    static
    func toolchain(module name:String, dependencies:Int...) -> Self
    {
        .init(name: name, type: .binary, dependencies: .init(modules: dependencies))
    }
}
