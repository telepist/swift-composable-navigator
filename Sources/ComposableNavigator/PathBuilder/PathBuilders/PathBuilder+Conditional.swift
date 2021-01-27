import SwiftUI

public extension PathBuilders {
  /**
   The conditional path builder controls which path builder is reponsible for building the routing path based on condition.

   In some cases, you want to make sure that the user will never be able to reach certain parts of your application. For example, you might want to show a login screen as long the user hasn't logged in. For these cases, you can use a conditional path builders.

   # Example
   ```swift
   .conditional(
    either: HomeScreen.builder(store: homeStore),
    or: LoginScreen.builder(store: loginStore),
    basedOn: { user.isLoggedIn }
   )
   ```

   The example here would never built routing paths using the HomeScreen.nuilder if the user isn't logged in. The condition is checked on each change of the routing path.

   - Parameters:
      - either:
        PathBuilder used to build the routing path, if the condition is true.
      - or:
        PathBuilder used to build the routing path, if the condition is false.
      - basedOn:
        Condition evaluated every time the routing path is built.
  */
  static func conditional<
    If: PathBuilder,
    Else: PathBuilder
  >(
    either: If,
    or: Else,
    basedOn condition: @escaping () -> Bool
  ) -> some PathBuilder {
    PathBuilders.if(
        condition,
        then: either,
        else: or
    )
  }

  /**
   The if path builder controls which path builder is reponsible for building the routing path based on condition.

   In some cases, you want to make sure that the user will never be able to reach certain parts of your application. For example, you might want to show a login screen as long the user hasn't logged in. For these cases, you can use a conditional path builders.

   # Example
   ```swift
   .if(
    { user.isLoggedIn },
    then: HomeScreen.builder(store: homeStore)
   )
   ```

   The example here would never built routing paths using the HomeScreen.nuilder if the user isn't logged in. The condition is checked on each change of the routing path.

   - Parameters:
      - condition:
        Condition evaluated every time the routing path is built.
      - then:
        PathBuilder used to build the routing path, if the condition is true.
   */
  static func `if`<If: PathBuilder>(
    _ condition: @escaping () -> Bool,
    then builder: If
  ) -> some PathBuilder {
    _PathBuilder<If.Content>(
      buildPath: { path -> If.Content? in
        if condition() {
          return builder.build(path: path)
        } else {
          return nil
        }
      }
    )
  }

  /**
   The if path builder controls which path builder is reponsible for building the routing path based on condition.

   In some cases, you want to make sure that the user will never be able to reach certain parts of your application. For example, you might want to show a login screen as long the user hasn't logged in. For these cases, you can use a conditional path builders.

   # Example
   ```swift
   .if(
    { user.isLoggedIn },
    then: HomeScreen.builder(store: homeStore),
    else: LoginScreen.builder(store: loginStore)
   )
   ```

   The example here would never built routing paths using the HomeScreen.nuilder if the user isn't logged in. The condition is checked on each change of the routing path.

   - Parameters:
      - condition:
        Condition evaluated every time the routing path is built.
      - then:
        PathBuilder used to build the routing path, if the condition is true.
      - else:
        PathBuilder used to build the routing path, if the condition is false.
   */
  static func `if`<If: PathBuilder, Else: PathBuilder>(
    _ condition: @escaping () -> Bool,
    then thenBuilder: If,
    else elseBuilder: Else
  ) -> some PathBuilder {
    _PathBuilder<EitherAB<If.Content, Else.Content>>(
      buildPath: { path -> EitherAB<If.Content, Else.Content>? in
        if condition(), let this = thenBuilder.build(path: path) {
          return .a(this)
        } else if let that = elseBuilder.build(path: path) {
          return .b(that)
        } else {
          return nil
        }
      }
    )
  }

  /**
   The ifLet path builder unwraps an optional value and provides it to the path builder defining closure.

   # Example
   ```swift
   .if(
      let: { store.detailStore },
      then: { detailStore in
        DetailScreen.builder(store: detailStore)
      },
      else: // fallback if the value is not set.
   )
   ```
   - Parameters:
      - let:
        Closure unwrapping a value.
      - then:
        Closure defining the path builder based on the unwrapped screen object.
      - else:
        Fallback pathbuilder used if the screen cannot be unwrapped.
   */
  static func `if`<LetContent, If: PathBuilder, Else: PathBuilder>(
    `let`: @escaping () -> LetContent?,
    then: @escaping (LetContent) -> If,
    else: Else
  ) -> some PathBuilder {
    _PathBuilder<EitherAB<If.Content, Else.Content>>(
      buildPath: { path -> EitherAB<If.Content, Else.Content>? in
        guard let letContent = `let`() else {
          return `else`.build(path: path).flatMap(EitherAB.b)
        }
        return then(letContent).build(path: path).flatMap(EitherAB.a)
      }
    )
  }

  /**
   The if screen path builder unwraps a screen, if the path element matches the screen type, and provides it to the path builder defining closure.

   ```swift
   .if(
    screen: { (screen: DetailScreen) in
      DetailScreen.builder(store.detailStore(for: screen.id))
    },
    else: // fallback
   )
   ```

   - Parameters:
      - screen:
        Closure defining the path builder based on the unwrapped screen object.
      - else:
        Fallback pathbuilder used if the screen cannot be unwrapped.
   */
  static func `if`<S: Screen, If: PathBuilder, Else: PathBuilder>(
    screen pathBuilder: @escaping (S) -> If,
    else: Else
  ) -> some PathBuilder {
    _PathBuilder<EitherAB<If.Content, Else.Content>>(
      buildPath: { path -> EitherAB<If.Content, Else.Content>? in
        guard let unwrappedScreen: S = path.first?.content.unwrap() else {
          return `else`.build(path: path).flatMap(EitherAB.b)
        }

        return pathBuilder(unwrappedScreen).build(path: path).flatMap(EitherAB.a)
      }
    )
  }

  /**
   The if screen path builder unwraps a screen, if the path element matches the screen type, and provides it to the path builder defining closure.

   ```swift
   .if(
    screen: { (screen: DetailScreen) in
      DetailScreen.builder(store.detailStore(for: screen.id))
    }
   )
   ```

   - Parameters:
      - screen:
        Closure defining the path builder based on the unwrapped screen object.
   */
  static func `if`<S: Screen, If: PathBuilder>(
    screen pathBuilder: @escaping (S) -> If
  ) -> some PathBuilder {
    PathBuilders.if(
      screen: pathBuilder,
      else: PathBuilders.empty
    )
  }
}
