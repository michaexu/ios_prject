import Foundation

private final class AppLocalizationBundleToken {}

enum AppLanguage: String, CaseIterable {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ja
    case ko
    case fr
    case de
    case es
    case ptBR = "pt-BR"
    case it
    case ru
    case ar

    static func resolve(preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        for preferredLanguage in preferredLanguages {
            let normalized = preferredLanguage.lowercased()

            if normalized.hasPrefix("zh-hant") || normalized.hasPrefix("zh-tw") || normalized.hasPrefix("zh-hk") {
                return .zhHant
            }
            if normalized.hasPrefix("zh-hans") || normalized.hasPrefix("zh-cn") || normalized.hasPrefix("zh-sg") || normalized == "zh" {
                return .zhHans
            }
            if normalized.hasPrefix("pt-br") || normalized.hasPrefix("pt") {
                return .ptBR
            }
            if normalized.hasPrefix("ja") {
                return .ja
            }
            if normalized.hasPrefix("ko") {
                return .ko
            }
            if normalized.hasPrefix("fr") {
                return .fr
            }
            if normalized.hasPrefix("de") {
                return .de
            }
            if normalized.hasPrefix("es") {
                return .es
            }
            if normalized.hasPrefix("it") {
                return .it
            }
            if normalized.hasPrefix("ru") {
                return .ru
            }
            if normalized.hasPrefix("ar") {
                return .ar
            }
            if normalized.hasPrefix("en") {
                return .en
            }
        }

        return .en
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

enum AppSound: String, CaseIterable {
    case beep
    case chime
    case tone

    var identifier: String {
        rawValue
    }

    var localizationKey: String {
        switch self {
        case .beep:
            return "settings.sound_option.beep"
        case .chime:
            return "settings.sound_option.chime"
        case .tone:
            return "settings.sound_option.tone"
        }
    }

    static func normalizedIdentifier(for storedValue: String) -> String {
        switch storedValue {
        case AppSound.beep.identifier, "Bell", "嘀嘀嘀":
            return AppSound.beep.identifier
        case AppSound.chime.identifier, "叮叮叮":
            return AppSound.chime.identifier
        case AppSound.tone.identifier, "嘟嘟嘟":
            return AppSound.tone.identifier
        default:
            return AppSound.beep.identifier
        }
    }

    static func displayName(for identifier: String, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let normalizedIdentifier = normalizedIdentifier(for: identifier)
        let sound = AppSound(rawValue: normalizedIdentifier) ?? .beep
        return AppLocalization.text(sound.localizationKey, preferredLanguages: preferredLanguages)
    }
}

enum AppLocalization {
    private static let fallbackLanguage = AppLanguage.en.rawValue
    private static let catalog: [String: [String: String]] = loadCatalog()

    static func text(_ key: String, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let language = AppLanguage.resolve(preferredLanguages: preferredLanguages).rawValue
        return catalog[language]?[key] ?? catalog[fallbackLanguage]?[key] ?? key
    }

    static func format(_ key: String, _ arguments: CVarArg..., preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let format = text(key, preferredLanguages: preferredLanguages)
        let locale = AppLanguage.resolve(preferredLanguages: preferredLanguages).locale
        return String(format: format, locale: locale, arguments: arguments)
    }

    static func currentLocale(preferredLanguages: [String] = Locale.preferredLanguages) -> Locale {
        AppLanguage.resolve(preferredLanguages: preferredLanguages).locale
    }

    static func weekdaySymbolsMondayFirst(preferredLanguages: [String] = Locale.preferredLanguages) -> [String] {
        let formatter = DateFormatter()
        let language = AppLanguage.resolve(preferredLanguages: preferredLanguages)
        formatter.locale = language.locale
        let symbols = formatter.shortStandaloneWeekdaySymbols ?? formatter.shortWeekdaySymbols ?? []
        guard symbols.count == 7 else { return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] }
        let mondayFirst = Array(symbols[1...6]) + [symbols[0]]
        return mondayFirst.map { compactWeekdaySymbol($0, language: language) }
    }

    private static func loadCatalog() -> [String: [String: String]] {
        let bundles = [Bundle.main, Bundle(for: AppLocalizationBundleToken.self)] + Bundle.allBundles + Bundle.allFrameworks

        for bundle in bundles {
            guard let url = bundle.url(forResource: "AppLocalizations", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let catalog = try? JSONDecoder().decode([String: [String: String]].self, from: data) else {
                continue
            }

            return catalog
        }

        return [:]
    }

    private static func compactWeekdaySymbol(_ symbol: String, language: AppLanguage) -> String {
        switch language {
        case .zhHans:
            return symbol.replacingOccurrences(of: "周", with: "")
        case .zhHant:
            return symbol.replacingOccurrences(of: "週", with: "")
        default:
            return symbol
        }
    }
}

enum AppTextFormatters {
    static func workRestSummary(work: Int, rest: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        AppLocalization.format("duration.work_rest_seconds", work, rest, preferredLanguages: preferredLanguages)
    }

    static func sessionCount(_ count: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        AppLocalization.format("stats.value.sessions", count, preferredLanguages: preferredLanguages)
    }

    static func streakDays(_ days: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        AppLocalization.format("stats.value.days", days, preferredLanguages: preferredLanguages)
    }

    static func rounds(_ count: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        AppLocalization.format("program.value.rounds", count, preferredLanguages: preferredLanguages)
    }

    static func roundProgress(current: Int, total: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        AppLocalization.format("timer.round_progress", current, total, preferredLanguages: preferredLanguages)
    }

    static func overviewDuration(_ seconds: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        if seconds == 0 {
            return AppLocalization.text("duration.zero_minutes", preferredLanguages: preferredLanguages)
        }

        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return AppLocalization.format("duration.hours_minutes", hours, minutes, preferredLanguages: preferredLanguages)
        }

        return AppLocalization.format("duration.minutes", max(minutes, 1), preferredLanguages: preferredLanguages)
    }

    static func recordDuration(_ seconds: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let minutes = seconds / 60
        if minutes > 0 {
            return AppLocalization.format("duration.minutes", minutes, preferredLanguages: preferredLanguages)
        }

        return AppLocalization.format("duration.seconds", seconds, preferredLanguages: preferredLanguages)
    }

    static func previewDuration(_ seconds: Int, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return AppLocalization.format("duration.minutes_seconds", minutes, remainingSeconds, preferredLanguages: preferredLanguages)
    }

    static func localizedDate(_ date: Date, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLocalization.currentLocale(preferredLanguages: preferredLanguages)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func localizedDateTime(_ date: Date, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLocalization.currentLocale(preferredLanguages: preferredLanguages)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
