/// A macro that generates a nested factory type for the enum it’s attached to.
///
/// This macro produces a nested type named `Factory`. It has a computed property
/// for each case of the original enum, which returns that case.
///
/// You can exclude cases from the factory type by passing their names as arguments
/// to the macro. If the case name is written in backticks, the string literal
/// should not include the backticks.
///
/// The factory type will include an `@inlinable internal` initializer that takes
/// no arguments. The factory type itself has zero size.
@attached(member, names: named(Factory))
public
macro GenerateDynamicMemberFactory(excluding:String...) = #externalMacro(
    module: "UnidocMacros",
    type: "GenerateDynamicMemberFactory")
