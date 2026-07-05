import XCTest
@testable import Interval_Timer

final class AppLocalizationTests: XCTestCase {
    func testResolvedLanguageFallsBackToEnglishWhenPreferredLanguageUnsupported() {
        XCTAssertEqual(AppLanguage.resolve(preferredLanguages: ["pl-PL"]), .en)
    }

    func testResolvedLanguageMatchesSupportedRegionalCodes() {
        XCTAssertEqual(AppLanguage.resolve(preferredLanguages: ["zh-CN"]), .zhHans)
        XCTAssertEqual(AppLanguage.resolve(preferredLanguages: ["pt-BR"]), .ptBR)
        XCTAssertEqual(AppLanguage.resolve(preferredLanguages: ["ar-SA"]), .ar)
    }

    func testPresetProgramsExposeLocalizedDisplayNamesForSupportedLanguages() {
        let program = Program.presetPrograms[1]

        XCTAssertEqual(program.displayName(preferredLanguages: ["en"]), "7-Minute Workout")
        XCTAssertEqual(program.displayName(preferredLanguages: ["zh-Hans"]), "7分钟训练")
        XCTAssertEqual(program.displayName(preferredLanguages: ["fr"]), "Entrainement de 7 minutes")
    }

    func testSoundOptionNormalizesLegacyStoredLabelsToStableIdentifiers() {
        XCTAssertEqual(AppSound.normalizedIdentifier(for: "嘀嘀嘀"), AppSound.beep.identifier)
        XCTAssertEqual(AppSound.normalizedIdentifier(for: "叮叮叮"), AppSound.chime.identifier)
        XCTAssertEqual(AppSound.normalizedIdentifier(for: "嘟嘟嘟"), AppSound.tone.identifier)
        XCTAssertEqual(AppSound.normalizedIdentifier(for: AppSound.tone.identifier), AppSound.tone.identifier)
    }
}
