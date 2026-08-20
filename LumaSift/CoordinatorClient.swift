import Foundation

enum CoordinatorError: LocalizedError { case invalidURL; case insecureURL; case response(Int, String); case emptyPayload
    var errorDescription: String? { switch self { case .invalidURL: return "Enter a valid coordinator URL."; case .insecureURL: return "Coordinator URLs must use HTTPS."; case let .response(status, detail): return "Coordinator request failed (\(status)): \(detail)"; case .emptyPayload: return "Coordinator returned no usable data." } }
}

struct CoordinatorClient {
    let settings: CoordinatorSettings
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func request(path: String, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: settings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/") ) + path) else { throw CoordinatorError.invalidURL }
        guard url.scheme?.lowercased() == "https" else { throw CoordinatorError.insecureURL }
        guard !settings.token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw CoordinatorError.emptyPayload }
        var request = URLRequest(url: url); request.httpMethod = method; request.httpBody = body
        request.setValue("Bearer \(settings.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw CoordinatorError.emptyPayload }
        guard (200...299).contains(http.statusCode) else { throw CoordinatorError.response(http.statusCode, String(data: data, encoding: .utf8)?.prefix(240).description ?? "") }
        return try decoder.decode(type, from: data)
    }

    func status() async throws -> LumaProgress { try await send(request(path: "/api/lumasift/status"), as: LumaProgress.self) }
    func plan() async throws -> LumaPlan { try await send(request(path: "/api/lumasift/plan"), as: LumaPlan.self) }
    func start(_ types: [String]) async throws -> LumaProgress { try await send(request(path: "/api/lumasift/start", method: "POST", body: try encoder.encode(StartRequest(selected_types: types))), as: LumaProgress.self) }
    func apply(_ id: String) async throws -> LumaPlan { try await send(request(path: "/api/lumasift/plan/apply", method: "POST", body: try encoder.encode(ApplyRequest(plan_id: id))), as: LumaPlan.self) }
}
