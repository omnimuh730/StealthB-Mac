import Foundation

struct Bookmark: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var url: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, url: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.url = url
        self.createdAt = createdAt
    }
}
