import ModuleGraphs
import TraceableErrors

extension Compiler
{
    public
    struct CultureError:Error, Sendable
    {
        public
        let underlying:any Error
        public
        let culture:ModuleIdentifier

        public
        init(underlying:any Error, culture:ModuleIdentifier)
        {
            self.underlying = underlying
            self.culture = culture
        }
    }
}
extension Compiler.CultureError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.culture == rhs.culture && lhs.underlying == rhs.underlying
    }
}
extension Compiler.CultureError:TraceableError
{
    public
    var notes:[String]
    {
        ["While compiling culture '\(self.culture)'."]
    }
}
