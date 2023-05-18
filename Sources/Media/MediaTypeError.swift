public
struct MediaTypeError:Error, Equatable, Sendable
{
    public
    let expected:MediaType
    public
    let encountered:MediaType

    public
    init(_ encountered:MediaType, expected:MediaType)
    {
        self.expected = expected
        self.encountered = encountered
    }
}
