import LinkResolution
import MarkdownSemantics
import SourceDiagnostics
import UCF

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

        private
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
    mutating
    func index(article:Markdown.SemanticDocument, id scope:Int32?)
    {
        let anchors:SSGC.AnchorTable = self.anchors.index(
            article: article.details,
            id: scope)

        func rewrite(_ target:inout Markdown.InlineHyperlink.Target?)
        {
            guard
            case .fragment(var spelling)? = target
            else
            {
                return
            }

            switch anchors[normalizing: spelling.string]
            {
            case .success(let fragment):
                spelling.string = fragment
                target = .fragment(spelling)

            case .failure(let error):
                self.diagnostics[spelling.source] = error
            }
        }

        article.overview?.sanitize(with: rewrite)
        article.details.traverse
        {
            if  case let block as Markdown.BlockProse = $0
            {
                block.sanitize(with: rewrite)
            }
        }
    }

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
