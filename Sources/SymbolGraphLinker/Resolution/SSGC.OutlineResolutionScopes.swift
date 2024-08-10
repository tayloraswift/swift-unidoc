import LinkResolution
import Symbols
import UCF

extension SSGC
{
    @_spi(testable) public
    struct OutlineResolutionScopes
    {
        let resources:[String: SSGC.Resource]
        let codelink:UCF.ResolutionScope
        let doclink:UCF.ArticleScope
        let origin:Int32?

        private
        init(resources:[String: SSGC.Resource],
            codelink:UCF.ResolutionScope,
            doclink:UCF.ArticleScope,
            origin:Int32?)
        {
            self.resources = resources
            self.codelink = codelink
            self.doclink = doclink
            self.origin = origin
        }
    }
}
extension SSGC.OutlineResolutionScopes
{
    /// Creates resolution scopes.
    ///
    /// -   Parameters:
    ///     -   namespace:
    ///         A namespace override, which supplants the module culture for codelink
    ///         resolutions only, if non-nil.
    ///     -   context:
    ///         The module context, which defines the module qualifier for doclink
    ///         resolutions, and also codelink resolutions if `namespace` is nil.
    ///     -   origin:
    ///         The id of the current documentation being linked. This will be used to optimize
    ///         fragment links that point to locations on the current page.
    ///     -   scope:
    ///         Additional implicit path components for codelink resolutions only.
    @_spi(testable) public
    init(namespace:Symbol.Module? = nil,
        context:SSGC.Linker.Context,
        origin:Int32?,
        scope:[String] = [])
    {
        self.init(resources: context.resources,
            codelink: .init(namespace: namespace ?? context.id,
                imports: [],
                path: scope),
            doclink: .init(namespace: context.id),
            origin: origin)
    }
}
