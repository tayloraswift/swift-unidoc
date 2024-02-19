import CodelinkResolution
import DoclinkResolution
import SourceDiagnostics

extension SSGC.Linker
{
    struct Tables:~Copyable
    {
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        var codelinks:CodelinkResolver<Int32>.Table
        var doclinks:DoclinkResolver.Table

        init(diagnostics:Diagnostics<SSGC.Symbolicator> = .init(),
            codelinks:CodelinkResolver<Int32>.Table = .init(),
            doclinks:DoclinkResolver.Table = .init())
        {
            self.diagnostics = diagnostics
            self.codelinks = codelinks
            self.doclinks = doclinks
        }
    }
}
extension SSGC.Linker.Tables
{
    mutating
    func resolving<Success>(with scopes:SSGC.OutlineResolutionScopes,
        do body:(inout SSGC.Outliner) throws -> Success) rethrows -> Success
    {
        let codelinks:CodelinkResolver<Int32>.Table = self.codelinks
        let doclinks:DoclinkResolver.Table = self.doclinks

        var outliner:SSGC.Outliner = .init(resolver: .init(
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
