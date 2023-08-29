import Availability

extension Availability
{
    var notice:String?
    {
        self.universal?.notice ??
        self.agnostic[.swift]?.notice("Swift") ??
        self.agnostic[.swiftPM]?.notice("SwiftPM")
    }
}
