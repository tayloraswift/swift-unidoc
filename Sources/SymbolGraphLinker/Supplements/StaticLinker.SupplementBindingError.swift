import CodelinkResolution
import Codelinks
import UnidocDiagnostics

extension StaticLinker
{
    struct SupplementBindingError:Error
    {
        let resolved:SupplementBinding
        let codelink:Codelink

        init(_ resolved:SupplementBinding,
            codelink:Codelink)
        {
            self.resolved = resolved
            self.codelink = codelink
        }
    }
}
extension StaticLinker.SupplementBindingError
{
    private
    var message:String
    {
        switch self.resolved
        {
        case .none(in: let culture):
            """
                article binding '\(self.codelink)' does not refer to a declaration \
                in its module, \(culture)
                """

        case .vector:
            """
                article binding '\(self.codelink)' cannot refer to a vector symbol
                """
        }
    }
}
extension StaticLinker.SupplementBindingError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static
    func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self.resolved
        {
        case .none(in: let culture):
            output[.warning] = """
            article binding '\(self.codelink)' does not refer to a declaration \
            in its module, \(culture)
            """

        case .vector:
            output[.warning] = """
            article binding '\(self.codelink)' cannot refer to a vector symbol
            """
        }
    }

    var notes:[Note]
    {
        switch self.resolved
        {
        case .none(in: _):
            []

        case .vector(let feature, self: _):
            [.init(suggested: feature)]
        }
    }
}
