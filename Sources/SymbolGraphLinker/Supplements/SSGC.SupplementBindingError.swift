import LinkResolution
import UCF
import SourceDiagnostics

extension SSGC
{
    struct SupplementBindingError:Error
    {
        let resolved:SupplementBinding
        let selector:UCF.Selector

        init(_ resolved:SupplementBinding,
            selector:UCF.Selector)
        {
            self.resolved = resolved
            self.selector = selector
        }
    }
}
extension SSGC.SupplementBindingError
{
    private
    var message:String
    {
        switch self.resolved
        {
        case .none(in: let culture):
            """
                article binding '\(self.selector)' does not refer to a declaration \
                in its module, \(culture)
                """

        case .vector:
            """
                article binding '\(self.selector)' cannot refer to a vector symbol
                """
        }
    }
}
extension SSGC.SupplementBindingError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    static
    func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        switch self.resolved
        {
        case .none(in: let culture):
            output[.warning] = """
            article binding '\(self.selector)' does not refer to a declaration \
            in its module, \(culture)
            """

        case .vector:
            output[.warning] = """
            article binding '\(self.selector)' cannot refer to a vector symbol
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
