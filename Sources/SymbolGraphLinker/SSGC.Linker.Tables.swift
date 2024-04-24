import LinkResolution
import MarkdownSemantics
import SourceDiagnostics

extension SSGC.Linker
{
    @_spi(testable) public
    struct Tables:~Copyable
    {
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        @_spi(testable) public
        var codelinks:CodelinkResolver<Int32>.Table
        @_spi(testable) public
        var doclinks:DoclinkResolver.Table

        var anchors:SSGC.AnchorResolver

        @_spi(testable) public
        init(diagnostics:Diagnostics<SSGC.Symbolicator> = .init(),
            codelinks:CodelinkResolver<Int32>.Table = .init(),
            doclinks:DoclinkResolver.Table = .init(),
            anchors:SSGC.AnchorResolver = .init())
        {
            self.diagnostics = diagnostics
            self.codelinks = codelinks
            self.doclinks = doclinks
            self.anchors = anchors
        }
    }
}
extension SSGC.Linker.Tables
{
    // mutating
    // func index(inlining resources:[String: SSGC.Resource],
    //     into article:SSGC.ArticleCollation,
    //     with parser:Markdown.SwiftLanguage?,
    //     for id:Int32) throws
    // {
    //     try self.inline(resources: resources,
    //         into: article.combined.details,
    //         with: parser)

    //     self.anchors.index(sections: article.combined.details, of: id)

    //     //  TODO: rewrite same-page anchors
    // }

    mutating
    func inline(resources:[String: SSGC.Resource],
        into sections:Markdown.SemanticSections,
        with parser:Markdown.SwiftLanguage?) throws
    {
        var last:[String?: SSGC.ResourceText] = [:]
        try sections.traverse
        {
            guard
            case let block as Markdown.BlockCodeReference = $0
            else
            {
                return
            }

            guard
            let file:String = block.file
            else
            {
                self.diagnostics[block.source] = SSGC.ResourceError.fileRequired(
                    argument: "file")
                return
            }
            guard
            let file:SSGC.Resource = resources[file]
            else
            {
                self.diagnostics[block.source] = SSGC.ResourceError.fileNotFound(file)
                return
            }

            let code:SSGC.ResourceText = try file.text()
            defer
            {
                last[block.title] = code
            }

            let base:SSGC.ResourceText?
            switch block.base
            {
            case .file(let file)?:
                if  let file:SSGC.Resource = resources[file]
                {
                    base = try file.text()
                    break
                }

                self.diagnostics[block.source] = SSGC.ResourceError.fileNotFound(file)
                base = nil

            case .auto?:
                base = last[block.title]

            case nil:
                base = nil
            }

            block.inline(code: code, base: base, with: parser)
            block.link = .inline(file.id)
        }
    }
}
extension SSGC.Linker.Tables
{
    @_spi(testable) public mutating
    func resolving<Success>(with scopes:SSGC.OutlineResolutionScopes,
        do body:(inout SSGC.Outliner) throws -> Success) rethrows -> Success
    {
        let codelinks:CodelinkResolver<Int32>.Table = self.codelinks
        let doclinks:DoclinkResolver.Table = self.doclinks
        let anchors:SSGC.AnchorResolver = self.anchors

        var outliner:SSGC.Outliner = .init(resources: scopes.resources,
            resolver: .init(
                diagnostics: (consume self).diagnostics,
                codelinks: .init(table: codelinks, scope: scopes.codelink),
                doclinks: .init(table: doclinks, scope: scopes.doclink),
                anchors: anchors))

        do
        {
            let success:Success = try body(&outliner)
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks,
                anchors: anchors)
            return success
        }
        catch let error
        {
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks,
                anchors: anchors)
            throw error
        }
    }
}
