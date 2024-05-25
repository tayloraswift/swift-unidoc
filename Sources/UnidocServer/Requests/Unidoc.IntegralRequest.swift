import MD5
import Multiparts
import URI

extension Unidoc
{
    @frozen public
    struct IntegralRequest:Sendable
    {
        public
        let metadata:Metadata
        public
        let ordering:Ordering

        private
        init(metadata:Metadata, ordering:Ordering)
        {
            self.metadata = metadata
            self.ordering = ordering
        }
    }
}
extension Unidoc.IntegralRequest
{
    public
    init?(get metadata:Metadata)
    {
        var router:Unidoc.Router = .init(metadata)

        if  let ordering:Unidoc.IntegralRequest.Ordering = router.get()
        {
            self.init(metadata: metadata, ordering: ordering)
        }
        else
        {
            return nil
        }
    }

    public
    init?(post metadata:Metadata, body:borrowing [UInt8])
    {
        var router:Unidoc.Router = .init(metadata)

        if  let ordering:Unidoc.IntegralRequest.Ordering = router.post(body: body)
        {
            self.init(metadata: metadata, ordering: ordering)
        }
        else
        {
            return nil
        }
    }
}
