import Repositories

extension Compiler
{
    public
    struct ModuleError:Error, Equatable, Sendable
    {
        public
        let module:ModuleIdentifier

        public
        init(unexpected:ModuleIdentifier)
        {
            self.module = unexpected
        }
    }
}
extension Compiler.ModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        "Symbol graph part belongs to a different module '\(self.module)' than expected."
    }
}
