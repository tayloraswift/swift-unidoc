extension Compiler
{
    public
    struct FeatureError:Equatable, Error, Sendable
    {
        public
        let selftype:ScalarSymbolResolution

        public
        init(invalid selftype:ScalarSymbolResolution)
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
