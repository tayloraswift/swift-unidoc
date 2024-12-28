extension UCF
{
    enum SignaturePattern
    {
        case function([TypePattern], TypePattern?)
        case returns(TypePattern)
    }
}
