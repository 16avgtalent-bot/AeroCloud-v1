@testable import AeroCloudCore
import Foundation
import Testing

struct TrackTests {
    @Test("id стабилен и содержит источник")
    func idIsNamespacedBySource() {
        #expect(DemoTracks.midnightDrive.id == "demo:midnight-drive")
    }

    @Test("длительность форматируется как m:ss")
    func durationFormatting() {
        #expect(DemoTracks.midnightDrive.durationText == "3:34")
        #expect(DemoTracks.glassHorizon.durationText == "3:07")
    }

    @Test("demo-треки без аудио не считаются playable")
    func demoAvailability() {
        #expect(DemoTracks.midnightDrive.isPlayable == false)
    }

    @Test("каталог не содержит дублей id")
    func catalogHasUniqueIDs() {
        let ids = DemoTracks.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("нейтральные признаки заполнены")
    func neutralFeatures() {
        let features = TrackFeatures.neutral
        #expect(features.energy == 0.5)
        #expect(features.tempo == 110)
    }
}
