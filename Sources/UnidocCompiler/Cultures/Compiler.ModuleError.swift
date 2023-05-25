import ModuleGraphs

extension Compiler
{
    public
    struct ModuleError:Error, Equatable, Sendable
    {
        public
        let module:ModuleIdentifier
        public
        let part:String?

        public
        init(unexpected:ModuleIdentifier, part:String?)
        {
            self.module = unexpected
            self.part = part
        }
    }
}
extension Compiler.ModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Symbols from \(self.part.map { "'\($0)'" } ?? "<anonymous>") belong to \
        module '\(self.module)'.
        """
    }
}
