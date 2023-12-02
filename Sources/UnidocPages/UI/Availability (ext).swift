import Availability

extension Availability
{
    var renamed:String?
    {
        self.universal?.renamed ??
        self.agnostic[.swift]?.renamed ??
        self.agnostic[.swiftPM]?.renamed
    }

    var notice:String?
    {
        self.universal?.notice ??
        self.agnostic[.swift]?.notice("Swift") ??
        self.agnostic[.swiftPM]?.notice("SwiftPM")
    }
}
