// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Аккаунт
  internal static let account = L10n.tr("Localizable", "Account", fallback: "Аккаунт")
  /// Вы уверены?
  internal static let areYouSure = L10n.tr("Localizable", "Are you sure?", fallback: "Вы уверены?")
  /// Awesome player,
  /// вместе в будущее!
  internal static let awesomeMusicPlayerInTouchWithTomorrow = L10n.tr("Localizable", "AWESOME music player, in touch with tomorrow!", fallback: "Awesome player,\nвместе в будущее!")
  /// Awesome Player
  internal static let awesomePlayer = L10n.tr("Localizable", "Awesome Player", fallback: "Awesome Player")
  /// Отмена
  internal static let cancel = L10n.tr("Localizable", "Cancel", fallback: "Отмена")
  /// Подключите аккаунт Spotify
  internal static let connectYourSpotifyAccount = L10n.tr("Localizable", "Connect your Spotify account", fallback: "Подключите аккаунт Spotify")
  /// Продолжить со Spotify
  internal static let continueWithSpotify = L10n.tr("Localizable", "Continue with Spotify", fallback: "Продолжить со Spotify")
  /// Выйти
  internal static let disconnect = L10n.tr("Localizable", "Disconnect", fallback: "Выйти")
  /// Скрыть
  internal static let dismiss = L10n.tr("Localizable", "Dismiss", fallback: "Скрыть")
  /// EXPLICIT
  internal static let explicit = L10n.tr("Localizable", "EXPLICIT", fallback: "EXPLICIT")
  /// Исследовать
  internal static let explore = L10n.tr("Localizable", "Explore", fallback: "Исследовать")
  /// При загрузке профиля произошла ошибка
  internal static let failedToLoadUserData = L10n.tr("Localizable", "Failed to load User Data", fallback: "При загрузке профиля произошла ошибка")
  /// Трендовые плей-листы
  internal static let featuredPlaylists = L10n.tr("Localizable", "Featured Playlists", fallback: "Трендовые плей-листы")
  /// Добрый день!
  internal static let goodAfternoon = L10n.tr("Localizable", "Good Afternoon", fallback: "Добрый день!")
  /// Добрый Вечер!
  internal static let goodEvening = L10n.tr("Localizable", "Good Evening", fallback: "Добрый Вечер!")
  /// Доброе Утро!
  internal static let goodMorning = L10n.tr("Localizable", "Good Morning", fallback: "Доброе Утро!")
  /// Доброй Ночи!
  internal static let goodNight = L10n.tr("Localizable", "Good Night", fallback: "Доброй Ночи!")
  /// Привет
  internal static let hi = L10n.tr("Localizable", "Hi", fallback: "Привет")
  /// Понравившиеся
  internal static let likedSongs = L10n.tr("Localizable", "Liked Songs", fallback: "Понравившиеся")
  /// Понравившиеся песни отсутствуют
  internal static let noLikedSongs = L10n.tr("Localizable", "No liked songs", fallback: "Понравившиеся песни отсутствуют")
  /// Несколько исполнителей
  internal static let numerousArtists = L10n.tr("Localizable", "Numerous Artists", fallback: "Несколько исполнителей")
  /// Профиль
  internal static let profile = L10n.tr("Localizable", "Profile", fallback: "Профиль")
  /// Рекомендованные
  internal static let recommendedSongs = L10n.tr("Localizable", "Recommended Songs", fallback: "Рекомендованные")
  /// Перезагрузить
  internal static let reload = L10n.tr("Localizable", "Reload", fallback: "Перезагрузить")
  /// Настройки
  internal static let settings = L10n.tr("Localizable", "Settings", fallback: "Настройки")
  /// Войти
  internal static let signIn = L10n.tr("Localizable", "Sign In", fallback: "Войти")
  /// Выйти
  internal static let signOut = L10n.tr("Localizable", "Sign Out", fallback: "Выйти")
  /// Что-то пошло не так
  internal static let somethingWentWrong = L10n.tr("Localizable", "Something went wrong", fallback: "Что-то пошло не так")
  /// Попробуйте позже
  internal static let tryAgainLater = L10n.tr("Localizable", "Try again later", fallback: "Попробуйте позже")
  /// Посмотри на рекомендованные треки
  internal static let tryExploringOurRecommendationList = L10n.tr("Localizable", "Try exploring our recommendation list", fallback: "Посмотри на рекомендованные треки")
  /// Попробуйте перезагрузить приложение или нажмите кнопку 'Перезагрузить'
  internal static let tryRestartingAppOrPressReload = L10n.tr("Localizable", "Try restarting app or press reload", fallback: "Попробуйте перезагрузить приложение или нажмите кнопку 'Перезагрузить'")
  /// Открыть профиль
  internal static let viewProfile = L10n.tr("Localizable", "View Profile", fallback: "Открыть профиль")
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
