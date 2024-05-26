import MD5
import Multiparts
import URI

extension Unidoc
{
    @frozen public
    struct IntegralRequest:Sendable
    {
        public
        let incoming:IncomingRequest
        public
        let assignee:AnyOperation

        private
        init(incoming:IncomingRequest, assignee:AnyOperation)
        {
            self.incoming = incoming
            self.assignee = assignee
        }
    }
}
extension Unidoc.IntegralRequest
{
    public
    init?(get request:Unidoc.IncomingRequest)
    {
        var router:Unidoc.Router = .init(routing: request)

        if  let assignee:Unidoc.AnyOperation = router.get()
        {
            self.init(incoming: request, assignee: assignee)
        }
        else
        {
            return nil
        }
    }

    public
    init?(post request:Unidoc.IncomingRequest, body:borrowing [UInt8])
    {
        var router:Unidoc.Router = .init(routing: request)

        if  let assignee:Unidoc.AnyOperation = router.post(body: body)
        {
            self.init(incoming: request, assignee: assignee)
        }
        else
        {
            return nil
        }
    }
}
