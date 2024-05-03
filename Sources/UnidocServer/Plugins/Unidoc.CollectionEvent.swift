import HTML

extension Unidoc
{
    public
    protocol CollectionEvent:HTML.OutputStreamable, Sendable
    {
        static
        func caught(_ error:any Error) -> Self
    }
}
