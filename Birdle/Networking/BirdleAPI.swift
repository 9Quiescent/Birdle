import Foundation

enum BirdleAPIError: Error {
    case badURL, badResponse(Int), decode, network(Error), invalidImage
}

struct UploadOutcome {
    let ok: Bool
    let serverText: String
}

final class BirdleAPI {
    static let shared = BirdleAPI()
    private init() {}

    private let base = "https://easterbilby.net/birdle/api.php"

    // Download today’s puzzle (GET method)
    func fetchToday() async throws -> Birdle {
        try await fetchBirdle(from: base)      // default is always = current bird
    }

    // Download specific puzzle by id (GET method)
    func fetchByID(_ id: Int) async throws -> Birdle {
        try await fetchBirdle(from: "\(base)?action=download&id=\(id)")
    }

    // Grab bird names (GET method)
    func fetchAllNames() async throws -> [String] {
        // cache-buster so we don’t read stale JSON after an upload
        let url = try makeURL("\(base)?action=list&nocache=\(UUID().uuidString)")
        let (data, resp) = try await URLSession.shared.data(from: url)
        try ensure200(resp)
        let decoded = try JSONDecoder().decode(BirdNameList.self, from: data)
        return decoded.birds
    }

    // Upload image (POST multipart/form-data) with server text back
    func uploadImageOutcome(
        jpegData: Data,
        filename: String,
        name: String,
        photographerName: String,
        license: String,
        photographerLink: String,
        birdleLink: String
    ) async throws -> UploadOutcome {

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: try makeURL(base))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func addField(_ key: String, _ value: String) {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        // action
        addField("action", "upload")
        addField("name", name)
        addField("photographer_name", photographerName)
        addField("license", license)
        addField("photographer_link", photographerLink)
        addField("birdle_link", birdleLink)

        // the actual image file
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(jpegData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        let (data, resp) = try await URLSession.shared.data(for: request)
        try ensure200(resp)

        let txt = String(data: data, encoding: .utf8) ?? ""
        if let decoded = try? JSONDecoder().decode(APIResult.self, from: data) {
            return .init(ok: decoded.result.lowercased() == "success", serverText: txt)
        }
        return .init(ok: txt.lowercased().contains("success"), serverText: txt)
    }

    // Helpers
    private func fetchBirdle(from urlString: String) async throws -> Birdle {
        let url = try makeURL(urlString)
        let (data, resp) = try await URLSession.shared.data(from: url)
        try ensure200(resp)
        do {
            return try JSONDecoder().decode(Birdle.self, from: data)
        } catch {
            // Some errors return { "result":"error" }
            if let txt = String(data: data, encoding: .utf8) {
                print("Server said:", txt)
            }
            throw BirdleAPIError.decode
        }
    }

    private func makeURL(_ s: String) throws -> URL {
        guard let u = URL(string: s) else { throw BirdleAPIError.badURL }
        return u
    }

    private func ensure200(_ resp: URLResponse) throws {
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        if code != 200 { throw BirdleAPIError.badResponse(code) }
    }
}

// Small Data helper
private extension Data {
    mutating func appendString(_ s: String) {
        if let d = s.data(using: .utf8) { append(d) }
    }
}
