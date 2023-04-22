extension Compiler
{
    public
    struct FeatureError:Equatable, Error, Sendable
    {
        public
        let selftype:Symbol.Scalar

        public
        init(invalid selftype:Symbol.Scalar)
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
