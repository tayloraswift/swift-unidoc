import ModuleGraphs
import Symbols

extension Repository.Root
{
    static
    func / (self:Self, file:FileSymbol) -> String
    {
        "\(self.path)/\(file)"
    }
}
