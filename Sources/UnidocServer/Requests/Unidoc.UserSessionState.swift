import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct UserSessionState:Sendable
    {
        public
        let authorization:Authorization
        public
        let request:URI
        public
        let format:RenderFormat

        @inlinable public
        init(authorization:Authorization, request:URI, format:RenderFormat)
        {
            self.authorization = authorization
            self.request = request
            self.format = format
        }
    }
}
