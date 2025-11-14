import Foundation

struct Birdle: Codable, Identifiable, Equatable {
    let name: String
    let image: String               // e.g. "0008"
    let photographer: String
    let license: String
    let photographer_link: String
    let bird_link: String

    var id: String { image }

    func imageURL(for index: Int) -> URL {
        // 0...4 are hints; 5 is the final image
        URL(string: "https://easterbilby.net/birdle/\(image)\(index).jpg")!
    }
}

struct BirdNameList: Codable {
    let date: String
    let birds: [String]
}

struct APIResult: Codable { let result: String }   // for upload { "result":"success" }

