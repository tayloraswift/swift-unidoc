import HTML
import Signatures

extension Unidoc
{
    /// A `WhereClause` binds a list of generic requirements to a ``VertexContext``.
    ///
    /// Usually, you would not initialize a `WhereClause` directly, but rather use the `|`
    /// operator, which elides the clause if the list of requirements is empty.
    struct WhereClause
    {
        private
        let requirements:[GenericConstraint<Unidoc.Scalar>]
        private
        let context:any VertexContext

        init(requirements:[GenericConstraint<Unidoc.Scalar>], context:any VertexContext)
        {
            self.requirements = requirements
            self.context = context
        }
    }
}
extension Unidoc.WhereClause:RandomAccessCollection
{
    var startIndex:Int { self.requirements.startIndex }
    var endIndex:Int { self.requirements.endIndex }

    subscript(index:Int) -> Requirement { self.requirements[index] | self.context }
}
extension Unidoc.WhereClause:HTML.OutputStreamable
{
    static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        var first:Bool = true
        for clause:Requirement in self
        {
            if  first
            {
                first = false
                code[.span] { $0.highlight = .keyword } = "where"
                code += " "
            }
            else
            {
                code += ", "
            }

            code += clause
        }
    }
}
