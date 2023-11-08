public
protocol RawRepresentableByIntegerEncoding<RawValue>:RawRepresentable
    where RawValue:ExpressibleByIntegerLiteral
{
    init(rawValue:RawValue)
}
