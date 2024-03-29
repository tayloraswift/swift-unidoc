// import JSON

// extension Unidoc
// {
//     @frozen public
//     struct BuildSelection
//     {
//         public
//         let package:Package
//         public
//         let version:VersionSeries?

//         @inlinable public
//         init(package:Package, version:VersionSeries?)
//         {
//             self.package = package
//             self.version = version
//         }
//     }
// }
// extension Unidoc.BuildSelection
// {
//     @frozen public
//     enum CodingKey:String, Sendable
//     {
//         case package
//         case version
//     }
// }
// extension Unidoc.BuildSelection:JSONObjectEncodable
// {
//     public
//     func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
//     {
//         json[.package] = self.package
//         json[.version] = self.version
//     }
// }
// extension Unidoc.BuildSelection:JSONObjectDecodable
// {
//     public
//     init(json:JSON.ObjectDecoder<CodingKey>) throws
//     {
//         self.init(
//             package: try json[.package].decode(),
//             version: try json[.version]?.decode())
//     }
// }
