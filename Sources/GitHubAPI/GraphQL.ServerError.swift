import JSON

extension GraphQL
{
    @frozen public
    struct ServerError:Error
    {
        @usableFromInline
        let json:JSON.Array

        @inlinable internal
        init(json:JSON.Array)
        {
            self.json = json
        }
    }
}
