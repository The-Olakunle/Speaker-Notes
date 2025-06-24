import Foundation

struct Note: Identifiable, Codable, Equatable, Hashable{
    var id = UUID()
    var title: String
    var body: String
    var createdAt: Date = Date()
}
