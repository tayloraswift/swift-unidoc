import Sources

extension StaticLinker
{
    struct Diagnostic
    {
        let problem:Problem
        let context:Context?

        init(_ problem:Problem, context:Context?)
        {
            self.problem = problem
            self.context = context
        }
    }
}
extension StaticLinker.Diagnostic:CustomStringConvertible
{
    public
    var description:String
    {
        """
        warning: \(problem)
        ---
        \(self.context?.lines ?? "")
        ---
        """
    }
}
