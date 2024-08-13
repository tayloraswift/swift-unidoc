import LinkResolution
import Symbols
import UCF

extension SSGC
{
    @_spi(testable) public
    struct OutlineResolverEnvironment
    {
        let origin:Int32?

        let causalLinks:UCF.ResolutionTable<UCF.CausalOverload>
        let resources:[String: SSGC.Resource]
        let codelink:UCF.ResolutionScope
        /// The scope to use when resolving `doc:` links. The namespace may be different from
        /// the namespace used for codelink resolution. For example, an article bound to an
        /// extension `Swift.Int.foo` uses `Swift` as the namespace for codelink resolution, but
        /// the article’s own culture for doclink resolution.
        let doclink:UCF.ArticleScope

        private
        init(origin:Int32?,
            causalLinks:UCF.ResolutionTable<UCF.CausalOverload>,
            resources:[String: SSGC.Resource],
            codelink:UCF.ResolutionScope,
            doclink:UCF.ArticleScope)
        {
            self.origin = origin
            self.causalLinks = causalLinks
            self.resources = resources
            self.codelink = codelink
            self.doclink = doclink
        }
    }
}
extension SSGC.OutlineResolverEnvironment
{
    /// Creates a link resolution environment.
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
    init(origin:Int32?,
        namespace:Symbol.Module? = nil,
        context:SSGC.Linker.Context,
        scope:[String] = [])
    {
        self.init(origin: origin,
            causalLinks: context.causalLinks,
            resources: context.resources,
            codelink: .init(namespace: namespace ?? context.id,
                imports: [],
                path: scope),
            doclink: .init(namespace: context.id))
    }
}
