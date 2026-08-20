import SwiftUI

@main
struct LumaSiftApp: App { var body: some Scene { WindowGroup { CoordinatorView() } } }

@MainActor
final class LumaModel: ObservableObject {
    @Published var settings = CoordinatorSettings()
    @Published var connected = false
    @Published var selected: Set<String> = ["video", "audio", "document", "image"]
    @Published var progress = LumaProgress()
    @Published var plan: LumaPlan?
    @Published var message: String?
    @Published var working = false
    private var client: CoordinatorClient?

    func connect() { run { let client = CoordinatorClient(settings: self.settings); self.progress = try await client.status(); self.plan = try? await client.plan(); self.client = client; self.connected = true; self.message = "Connected to the trusted LumaSift coordinator." } }
    func refresh() { run { guard let client = self.client else { throw CoordinatorError.emptyPayload }; self.progress = try await client.status(); self.plan = try? await client.plan() } }
    func start() { run { guard let client = self.client else { throw CoordinatorError.emptyPayload }; guard !self.selected.isEmpty else { throw CoordinatorError.emptyPayload }; self.progress = try await client.start(self.selected.sorted()); self.plan = nil; self.message = "The Windows coordinator is building a review-only exact-content plan." } }
    func apply() { run { guard let client = self.client, let plan = self.plan else { throw CoordinatorError.emptyPayload }; self.plan = try await client.apply(plan.id); self.progress = try await client.status(); self.message = "The coordinator revalidated and applied the approved quarantine plan." } }
    private func run(_ operation: @escaping () async throws -> Void) { working = true; message = nil; Task { defer { working = false }; do { try await operation() } catch { message = error.localizedDescription } } }
}

struct CoordinatorView: View {
    @StateObject private var model = LumaModel()
    @State private var confirm = false
    private let navy = Color(red: 7/255, green: 28/255, blue: 43/255)
    private let panel = Color(red: 13/255, green: 42/255, blue: 59/255)
    private let cyan = Color(red: 110/255, green: 231/255, blue: 1)
    private let gold = Color(red: 1, green: 233/255, blue: 110/255)

    var body: some View {
        ScrollView { VStack(spacing: 14) {
            hero
            if !model.connected { connectCard }
            if model.connected { selectionCard; progressCard; planCard }
            if let message = model.message { Text(message).foregroundStyle(cyan).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(panel, in: RoundedRectangle(cornerRadius: 16)) }
            Text("This companion never stores NAS credentials or displays raw coordinator source paths. Exact SHA-256 proof and recovery actions occur on the trusted Windows coordinator.").font(.footnote).foregroundStyle(.white.opacity(0.68)).padding(.vertical, 8)
        }.padding(18) }.background(navy.ignoresSafeArea()).tint(cyan).alert("Approve quarantine plan?", isPresented: $confirm) { Button("Keep reviewing", role: .cancel) {}; Button("Move to quarantine") { model.apply() } } message: { Text("The Windows coordinator will revalidate \(model.plan?.queued_file_count ?? 0) lower-ranked exact duplicates and move them to recoverable quarantine. Nothing is permanently erased.") }
    }

    private var hero: some View { VStack(alignment: .leading, spacing: 6) { Text("EXACT MEDIA RESOLUTION").font(.caption2.bold()).tracking(1.3).foregroundStyle(cyan); Text("LumaSift").font(.system(size: 38, weight: .black)); Text(model.connected ? "Connected companion · \(min(max(model.progress.percentage, 0), 100))% current plan status" : "Secure companion for your Windows coordinator").foregroundStyle(.white.opacity(0.72)) }.frame(maxWidth: .infinity, alignment: .leading).padding(22).background(panel, in: RoundedRectangle(cornerRadius: 24)).overlay(RoundedRectangle(cornerRadius: 24).stroke(cyan.opacity(0.35))) }

    private var connectCard: some View { VStack(alignment: .leading, spacing: 10) { Text("CONNECT A TRUSTED WINDOWS COORDINATOR").font(.caption.bold()).foregroundStyle(gold); TextField("HTTPS coordinator URL", text: $model.settings.baseURL).textInputAutocapitalization(.never).keyboardType(.URL).textFieldStyle(.roundedBorder); SecureField("Access token", text: $model.settings.token).textFieldStyle(.roundedBorder); Button("CONNECT") { model.connect() }.buttonStyle(.borderedProminent).disabled(model.working || model.settings.baseURL.isEmpty || model.settings.token.isEmpty) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20)) }

    private var selectionCard: some View { VStack(alignment: .leading, spacing: 10) { Text("SELECTED FILE TYPES").font(.caption.bold()).foregroundStyle(cyan); Text("The coordinator scans only the categories you approve; complete hashing remains mandatory.").font(.footnote).foregroundStyle(.white.opacity(0.7)); HStack { ForEach([("video","VIDEOS"),("audio","MP3"),("document","DOCX/PDF"),("image","IMAGES")], id: \.0) { type in Text(type.1).font(.caption.bold()).foregroundStyle(model.selected.contains(type.0) ? navy : .white.opacity(0.7)).padding(9).background(model.selected.contains(type.0) ? cyan : navy, in: Capsule()).onTapGesture { if model.selected.contains(type.0) { model.selected.remove(type.0) } else { model.selected.insert(type.0) } } } }.frame(maxWidth: .infinity, alignment: .leading) }.padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20)) }

    private var progressCard: some View { VStack(alignment: .leading, spacing: 10) { HStack { VStack(alignment: .leading) { Text(model.progress.phase.uppercased()).font(.headline); Text(model.progress.message).font(.footnote).foregroundStyle(.white.opacity(0.68)).lineLimit(2) }; Spacer(); Text("\(min(max(model.progress.percentage,0),100))%").font(.title.bold()).foregroundStyle(cyan) }; ProgressView(value: Double(min(max(model.progress.percentage,0),100)), total: 100).tint(cyan); Text("\(model.progress.current) / \(model.progress.total) · \(model.progress.files_considered) indexed").font(.caption).foregroundStyle(.white.opacity(0.65)); HStack { Button("BUILD EXACT PLAN") { model.start() }.buttonStyle(.borderedProminent).disabled(model.working || model.progress.scanning || model.selected.isEmpty); Button("REFRESH") { model.refresh() }.buttonStyle(.bordered).disabled(model.working) } }.padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20)) }

    private var planCard: some View { VStack(alignment: .leading, spacing: 10) { HStack { VStack(alignment: .leading) { Text("RESOLUTION PLAN").font(.caption.bold()).foregroundStyle(gold); Text(model.plan.map { "\($0.groups.count) exact groups · \($0.queued_file_count) queued · \(bytes($0.reclaimable_bytes)) recoverable" } ?? "No reviewable plan yet.").font(.footnote).foregroundStyle(.white.opacity(0.7)) }; Spacer(); if model.plan?.status == "ready_for_review" { Button("QUARANTINE") { confirm = true }.buttonStyle(.borderedProminent).disabled(model.working) } }; ForEach(model.plan?.groups ?? []) { group in VStack(alignment: .leading, spacing: 8) { Text("EXACT CONTENT GROUP · \(bytes(group.reclaimable_bytes))").font(.caption.bold()).foregroundStyle(cyan); ForEach(group.candidates) { candidate in VStack(alignment: .leading, spacing: 3) { Text(candidate.display_name).fontWeight(.bold).lineLimit(1); Text(candidate.disposition.replacingOccurrences(of: "_", with: " ").uppercased()).font(.caption.bold()).foregroundStyle(candidate.id == group.winner_id ? cyan : gold); Text(candidate.disposition_detail).font(.caption).foregroundStyle(.white.opacity(0.7)).lineLimit(2) }.frame(maxWidth: .infinity, alignment: .leading).padding(10).background(navy, in: RoundedRectangle(cornerRadius: 12)) } }.padding(12).background(panel.opacity(0.74), in: RoundedRectangle(cornerRadius: 15)) } }.padding(16).background(panel, in: RoundedRectangle(cornerRadius: 20)) }
    private func bytes(_ value: Int) -> String { value < 1_048_576 ? "\(value / 1024) KB" : String(format: "%.1f MB", Double(value) / 1_048_576) }
}
