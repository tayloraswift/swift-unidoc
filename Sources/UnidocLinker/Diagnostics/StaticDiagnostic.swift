import Sources

struct StaticDiagnostic
{
    let problem:Problem
    let context:Context?

    init(_ problem:Problem, context:Context?)
    {
        self.problem = problem
        self.context = context
    }
}
extension StaticDiagnostic:CustomStringConvertible
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
