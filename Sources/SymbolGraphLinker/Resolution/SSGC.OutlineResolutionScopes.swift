import LinkResolution
import Symbols

extension SSGC
{
    @_spi(testable) public
    struct OutlineResolutionScopes
    {
        let resources:[String: SSGC.Resource]
        let codelink:CodelinkResolver<Int32>.Scope
        let doclink:DoclinkResolver.Scope
        let origin:Int32?

        private
        init(resources:[String: SSGC.Resource],
            codelink:CodelinkResolver<Int32>.Scope,
            doclink:DoclinkResolver.Scope,
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
    ///     -   culture:
    ///         The module culture, which serves as the module qualifier for doclink
    ///         resolutions, and also codelink resolutions if `namespace` is nil.
    ///     -   origin:
    ///         The id of the current documentation being linked. This will be used to optimize
    ///         fragment links that point to locations on the current page.
    ///     -   scope:
    ///         Additional implicit path components for codelink resolutions only.
    @_spi(testable) public
    init(namespace:Symbol.Module? = nil,
        culture:SSGC.Linker.Culture,
        origin:Int32?,
        scope:[String] = [])
    {
        self.init(resources: culture.resources,
            codelink: .init(namespace: namespace ?? culture.id,
                imports: culture.imports,
                path: scope),
            doclink: .init(namespace: culture.id),
            origin: origin)
    }
}
