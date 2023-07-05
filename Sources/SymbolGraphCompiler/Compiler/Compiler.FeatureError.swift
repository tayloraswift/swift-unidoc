import Symbols

extension Compiler
{
    public
    struct FeatureError:Equatable, Error, Sendable
    {
        public
        let selftype:Symbol.Decl

        public
        init(invalid selftype:Symbol.Decl)
        {
            self.selftype = selftype
        }
    }
}
extension Compiler.FeatureError:CustomStringConvertible
{
    public
    var description:String
    {
        "Adding feature to invalid 'Self' type '\(self.selftype)'."
    }
}
