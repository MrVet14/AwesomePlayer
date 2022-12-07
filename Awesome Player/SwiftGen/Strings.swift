// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Localizable.strings
  ///   Awesome Player
  /// 
  ///   Created by Vitali Vyucheiski on 11/17/22.
  internal static let connectYourSpotifyAccount = L10n.tr("Localizable", "Connect your Spotify account", fallback: "Подключите аккаунт Spotify")
  /// Продолжить со Spotify
  internal static let continueWithSpotify = L10n.tr("Localizable", "Continue with Spotify", fallback: "Продолжить со Spotify")
  /// Выйти
  internal static let disconnect = L10n.tr("Localizable", "Disconnect", fallback: "Выйти")
  /// Скрыть
  internal static let dismiss = L10n.tr("Localizable", "Dismiss", fallback: "Скрыть")
  /// Что-то пошло не так
  internal static let somethingWentWrong = L10n.tr("Localizable", "Something went wrong", fallback: "Что-то пошло не так")
  /// Попробуйте позже
  internal static let tryAgainLater = L10n.tr("Localizable", "Try again later", fallback: "Попробуйте позже")
  /// Привет!
  internal static let welcome = L10n.tr("Localizable", "Welcome", fallback: "Привет!")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
