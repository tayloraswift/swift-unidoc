extension Unmanaged where Instance:AdditiveArithmetic
{
    public
    struct Nested<U> where Instance:Numeric, U:Sequence
    {
    }
}
