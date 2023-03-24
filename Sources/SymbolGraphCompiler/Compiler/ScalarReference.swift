// class ScalarReference
// {
//     final
//     let resolution:ScalarSymbolResolution
//     final
//     var address:UInt32

//     init(resolution:ScalarSymbolResolution)
//     {
//         self.resolution = resolution
//         self.address = .max
//     }
// }
// extension ScalarReference:Equatable
// {
//     static
//     func == (lhs:ScalarReference, rhs:ScalarReference) -> Bool
//     {
//         lhs === rhs
//     }
// }
// extension ScalarReference:Hashable
// {
//     final
//     func hash(into hasher:inout Hasher)
//     {
//         ObjectIdentifier.init(self).hash(into: &hasher)
//     }
// }
