extension Compiler
{
    public
    struct FeatureError:Equatable, Error, Sendable
    {
        public
        let selftype:ScalarSymbol

        public
        init(invalid selftype:ScalarSymbol)
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
