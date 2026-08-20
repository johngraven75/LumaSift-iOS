import Foundation

struct CoordinatorSettings: Codable, Equatable { var baseURL = ""; var token = "" }
struct StartRequest: Encodable { let selected_types: [String] }
struct ApplyRequest: Encodable { let plan_id: String }

struct LumaProgress: Codable, Equatable {
    var scanning = false
    var phase = "Ready"
    var current = 0
    var total = 0
    var percentage = 0
    var current_path: String?
    var files_considered = 0
    var message = "Connect a trusted Windows LumaSift coordinator to begin."
    var error: String?
}
struct Quality: Codable, Equatable { var reasons: [String] = []; var file_size_bytes = 0 }
struct Candidate: Codable, Identifiable, Equatable { let id: String; let display_name: String; let media_kind: String; let disposition: String; let disposition_detail: String; let quality: Quality }
struct LumaGroup: Codable, Identifiable, Equatable { let id: String; let winner_id: String; let reclaimable_bytes: Int; let candidates: [Candidate] }
struct LumaPlan: Codable, Equatable { let id: String; let status: String; let selected_types: [String]; let groups: [LumaGroup]; let reclaimable_bytes: Int; let queued_file_count: Int }
