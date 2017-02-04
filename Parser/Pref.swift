import Foundation

enum Pref: String {
    case paraAlign = "paraAlign"

    static func getUserDefaults() -> UserDefaults {
        return UserDefaults.init(suiteName: "com.jintin.swimat.config")!
    }

    static func isParaAlign() -> Bool {
        if let _ = getUserDefaults().object(forKey: Pref.paraAlign.rawValue) {
            return getUserDefaults().bool(forKey: Pref.paraAlign.rawValue)
        }
        return true
    }

    static func setParaAlign(isAlign: Bool) {
        getUserDefaults().set(isAlign, forKey: Pref.paraAlign.rawValue)
        getUserDefaults().synchronize()
    }

}

