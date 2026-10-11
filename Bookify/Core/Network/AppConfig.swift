import Foundation

enum AppConfig {
    static let baseURL: URL = {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "BookifyBaseURL") as? String,
           !raw.isEmpty,
           let url = URL(string: raw) {
            return url
        }
        #if DEV
        return makeURL("http://192.168.101.115:8080")
        #else
        return makeURL("https://bookify-backend-1qs6.onrender.com")
        #endif
    }()

    private static func makeURL(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("URL base inválida: \(string)")
        }
        return url
    }
}
