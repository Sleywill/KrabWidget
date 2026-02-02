import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct KrabWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> KrabWidgetEntry {
        KrabWidgetEntry(date: Date(), data: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (KrabWidgetEntry) -> Void) {
        let entry = KrabWidgetEntry(date: Date(), data: WidgetDataStore.shared.load())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<KrabWidgetEntry>) -> Void) {
        let data = WidgetDataStore.shared.load()
        let entry = KrabWidgetEntry(date: Date(), data: data)
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct KrabWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Widget Views
struct KrabStatusWidget: Widget {
    let kind: String = "KrabStatusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KrabWidgetProvider()) { entry in
            KrabWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Krab Status")
        .description("See your Krab assistant status and recent messages.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Entry View
struct KrabWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: KrabWidgetEntry
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.08, blue: 0.18),
                    Color(red: 0.15, green: 0.12, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Content based on size
            switch family {
            case .systemSmall:
                SmallWidgetView(data: entry.data)
            case .systemMedium:
                MediumWidgetView(data: entry.data)
            case .systemLarge:
                LargeWidgetView(data: entry.data)
            @unknown default:
                SmallWidgetView(data: entry.data)
            }
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(spacing: 8) {
            // Crab mascot
            Image("KrabMascot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .shadow(color: .red.opacity(0.5), radius: 10)
            
            // Status
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(data.isConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(data.isConnected ? "Connected" : "Offline")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text(data.crabMood.statusText)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Mascot
            VStack(spacing: 8) {
                Image("KrabMascot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .shadow(color: .red.opacity(0.5), radius: 10)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(data.isConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(data.isConnected ? "Online" : "Offline")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(width: 90)
            
            // Right: Message preview
            VStack(alignment: .leading, spacing: 8) {
                Text("KrabWidget")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let message = data.lastMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                } else {
                    Text(data.isConnected ? "No messages yet" : "Connect to start")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Powered by OpenClaw 🦀")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image("KrabMascot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("KrabWidget")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(data.isConnected ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(data.crabMood.statusText)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(data.crabMood.emoji)
                    .font(.title)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Content area
            VStack(alignment: .leading, spacing: 12) {
                if data.isConnected {
                    if let message = data.lastMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Message")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(message)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("🦀")
                                .font(.system(size: 50))
                            Text("Ready and waiting!")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Send a message to get started")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("😴")
                            .font(.system(size: 50))
                        Text("Not Connected")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Open KrabWidget app to connect")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Footer
            HStack {
                Text("Updated \(data.lastUpdate, style: .relative) ago")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
                
                Spacer()
                
                Text("Powered by OpenClaw")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    KrabStatusWidget()
} timeline: {
    KrabWidgetEntry(date: .now, data: .placeholder)
    KrabWidgetEntry(date: .now, data: .disconnected)
}

#Preview(as: .systemMedium) {
    KrabStatusWidget()
} timeline: {
    KrabWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemLarge) {
    KrabStatusWidget()
} timeline: {
    KrabWidgetEntry(date: .now, data: .placeholder)
}
