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

        private
        init(resources:[String: SSGC.Resource],
            codelink:CodelinkResolver<Int32>.Scope,
            doclink:DoclinkResolver.Scope)
        {
            self.resources = resources
            self.codelink = codelink
            self.doclink = doclink
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
    ///     -   scope:
    ///         Additional implicit path components for codelink resolutions only.
    @_spi(testable) public
    init(namespace:Symbol.Module? = nil,
        culture:SSGC.Linker.Culture,
        scope:[String] = [])
    {
        self.init(resources: culture.resources,
            codelink: .init(namespace: namespace ?? culture.module,
                imports: culture.imports,
                path: scope),
            doclink: .init(namespace: culture.module))
    }
}
