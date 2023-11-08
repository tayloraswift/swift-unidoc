@attached(extension, names: arbitrary, conformances: RawRepresentableByIntegerEncoding)
public
macro GenerateCasesByIntegerEncoding() = #externalMacro(
    module: "UnidocMacros",
    type: "GenerateCasesByIntegerEncoding")
