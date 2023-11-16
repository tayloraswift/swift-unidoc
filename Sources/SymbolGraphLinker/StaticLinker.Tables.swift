import CodelinkResolution
import DoclinkResolution
import UnidocDiagnostics

extension StaticLinker
{
    struct Tables:~Copyable
    {
        var diagnostics:DiagnosticContext<StaticSymbolicator>

        var codelinks:CodelinkResolver<Int32>.Table
        var doclinks:DoclinkResolver.Table

        init(diagnostics:DiagnosticContext<StaticSymbolicator> = .init(),
            codelinks:CodelinkResolver<Int32>.Table = .init(),
            doclinks:DoclinkResolver.Table = .init())
        {
            self.diagnostics = diagnostics
            self.codelinks = codelinks
            self.doclinks = doclinks
        }
    }
}
extension StaticLinker.Tables
{
    mutating
    func resolving<Success>(with scopes:StaticResolver.Scopes,
        do body:(inout StaticOutliner) throws -> Success) rethrows -> Success
    {
        let codelinks:CodelinkResolver<Int32>.Table = self.codelinks
        let doclinks:DoclinkResolver.Table = self.doclinks

        var outliner:StaticOutliner = .init(resolver: .init(
            diagnostics: (consume self).diagnostics,
            codelinks: .init(table: codelinks, scope: scopes.codelink),
            doclinks: .init(table: doclinks, scope: scopes.doclink)))

        do
        {
            let success:Success = try body(&outliner)
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks)
            return success
        }
        catch let error
        {
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks)
            throw error
        }
    }
}
