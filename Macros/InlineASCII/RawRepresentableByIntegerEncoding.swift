public
protocol RawRepresentableByIntegerEncoding<RawValue>:RawRepresentable
    where RawValue:ExpressibleByIntegerLiteral
{
    init(rawValue:RawValue)
}

@attached(extension, names: arbitrary, conformances: RawRepresentableByIntegerEncoding)
public
macro RawRepresentableByIntegerEncoding(_ strings:String...) = #externalMacro(
    module: "InlineValueMacros",
    type: "InlineASCII.ConstructorMacro")
