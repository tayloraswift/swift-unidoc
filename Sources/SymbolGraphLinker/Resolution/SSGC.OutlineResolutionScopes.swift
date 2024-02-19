import CodelinkResolution
import DoclinkResolution
import Symbols

extension SSGC
{
    struct OutlineResolutionScopes
    {
        let resources:[String: SSGC.Resource]
        let codelink:CodelinkResolver<Int32>.Scope
        //  Optional, in case we ever want to support some kind of neutrally-scoped linker mode.
        let doclink:DoclinkResolver.Scope?

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
    init(namespace:Symbol.Module? = nil,
        culture:SSGC.Linker.Culture,
        scope:[String] = [])
    {
        self.init(resources: culture.resources,
            codelink: .init(namespace: namespace ?? culture.module,
                imports: culture.imports,
                path: scope),
            doclink: .documentation(culture.module))
    }
}
