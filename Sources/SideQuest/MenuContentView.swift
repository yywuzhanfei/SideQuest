import SwiftUI

struct MenuContentView: View {
    @ObservedObject var store: ActivityStore

    @AppStorage("automaticNightMode") private var automaticNightMode = true
    @AppStorage("manualNightMode") private var manualNightMode = false

    @State private var filters = ActivityFilters()
    @State private var recommendation: Activity?
    @State private var newTitle = ""
    @State private var newDuration = 15
    @State private var newEnergy: ActivityEnergy = .low
    @State private var newCategory: ActivityCategory = .personal
    @State private var newUsesScreen = false
    @State private var newAllowedAtNight = true
    @State private var now = Date()

    private var automaticNightIsActive: Bool {
        guard automaticNightMode else { return false }
        let components = Calendar.current.dateComponents([.hour, .minute], from: now)
        let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        return minutes >= 22 * 60 + 30 || minutes < 5 * 60
    }

    private var nightMode: Bool {
        manualNightMode || automaticNightIsActive
    }

    private var visibleActivities: [Activity] {
        RecommendationEngine.filtered(
            activities: store.activities,
            filters: filters,
            nightMode: nightMode
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            recommendationCard
            filtersSection
            activityList
            Divider()
            addSection
            footer
        }
        .padding(16)
        .frame(width: 390, height: 590)
        .onAppear {
            now = Date()
            refreshRecommendationIfNeeded()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SideQuest")
                    .font(.title2.weight(.semibold))
                Text(nightMode ? "Night menu · keep it light" : "What can I do right now?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if nightMode {
                Label("Night", systemImage: "moon.stars.fill")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.quaternary, in: Capsule())
            }
        }
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let recommendation {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendation.title)
                            .font(.headline)
                        Text("\(recommendation.durationMinutes) min · \(recommendation.energy.label) energy · \(recommendation.category.label)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            } else {
                Text(visibleActivities.isEmpty ? "No quests match these filters." : "Let SideQuest choose for you.")
                    .foregroundStyle(.secondary)
            }

            Button {
                recommendation = RecommendationEngine.pick(
                    activities: store.activities,
                    filters: filters,
                    nightMode: nightMode
                )
            } label: {
                Label("Pick for me", systemImage: "dice.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(visibleActivities.isEmpty)
        }
        .padding(12)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Filters")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Menu {
                    Button("Any time") { filters.maxDuration = nil }
                    Button("5 min") { filters.maxDuration = 5 }
                    Button("15 min") { filters.maxDuration = 15 }
                    Button("30 min") { filters.maxDuration = 30 }
                    Button("60 min") { filters.maxDuration = 60 }
                } label: {
                    Label(durationLabel, systemImage: "clock")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }

            HStack(spacing: 12) {
                Toggle("Low energy", isOn: $filters.lowEnergyOnly)
                Toggle("No screen", isOn: $filters.noScreenOnly)
                Toggle("Fun", isOn: $filters.funOnly)
            }
            .toggleStyle(.checkbox)
            .font(.caption)
            .onChange(of: filters) { _ in
                recommendation = nil
            }
        }
    }

    private var activityList: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Available now")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(visibleActivities.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(visibleActivities) { activity in
                        HStack(spacing: 8) {
                            Button {
                                recommendation = activity
                            } label: {
                                HStack {
                                    Text(activity.title)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(activity.durationMinutes)m")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            Button(role: .destructive) {
                                if recommendation?.id == activity.id {
                                    recommendation = nil
                                }
                                store.remove(activity)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .frame(maxHeight: 150)
        }
    }

    private var addSection: some View {
        DisclosureGroup("Add a side quest") {
            VStack(alignment: .leading, spacing: 8) {
                TextField("e.g. Clean the fridge", text: $newTitle)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Stepper("\(newDuration) min", value: $newDuration, in: 5...180, step: 5)
                    Spacer()
                    Picker("Energy", selection: $newEnergy) {
                        ForEach(ActivityEnergy.allCases) { energy in
                            Text(energy.label).tag(energy)
                        }
                    }
                    .frame(width: 130)
                }

                Picker("Category", selection: $newCategory) {
                    ForEach(ActivityCategory.allCases) { category in
                        Text(category.label).tag(category)
                    }
                }

                HStack {
                    Toggle("Uses screen", isOn: $newUsesScreen)
                    Toggle("Night-safe", isOn: $newAllowedAtNight)
                }
                .toggleStyle(.checkbox)

                Button("Add") {
                    addActivity()
                }
                .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top, 8)
        }
        .font(.subheadline)
    }

    private var footer: some View {
        HStack {
            Menu {
                Toggle("Automatic after 10:30 PM", isOn: $automaticNightMode)
                Toggle("Night mode now", isOn: $manualNightMode)
                Divider()
                Button("Reset sample quests") {
                    recommendation = nil
                    store.resetToDefaults()
                }
            } label: {
                Label("Night settings", systemImage: "moon")
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private var durationLabel: String {
        guard let maxDuration = filters.maxDuration else { return "Any time" }
        return "≤ \(maxDuration) min"
    }

    private func addActivity() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        store.add(
            Activity(
                title: title,
                durationMinutes: newDuration,
                energy: newEnergy,
                category: newCategory,
                usesScreen: newUsesScreen,
                allowedAtNight: newAllowedAtNight
            )
        )

        newTitle = ""
        recommendation = nil
    }

    private func refreshRecommendationIfNeeded() {
        guard let recommendation else { return }
        if !visibleActivities.contains(where: { $0.id == recommendation.id }) {
            self.recommendation = nil
        }
    }
}
