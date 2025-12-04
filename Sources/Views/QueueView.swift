import SwiftUI

struct QueueView: View {
    @ObservedObject var queueManager: QueueManager
    var onOpenPreferences: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Queue items list (oldest at top, newest at bottom)
            if queueManager.items.isEmpty {
                // Empty state
                VStack {
                    Spacer()
                    Text("Queue is empty")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    Text("Copy something to get started")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        // Display items in order: index 0 = oldest (top)
                        ForEach(Array(queueManager.items.enumerated()), id: \.element.id) { index, item in
                            QueueItemRow(
                                item: item,
                                index: index,
                                isOldest: index == 0,
                                queueManager: queueManager
                            )
                        }
                    }
                    .padding(8)
                }
            }
            
            Divider()
            
            // Footer with settings and clear
            HStack(spacing: 12) {
                // Settings button
                Button {
                    print("⚙️ Gear button clicked!")
                    onOpenPreferences?()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .help("Settings")
                
                Spacer()
                
                // Clear button
                Button {
                    queueManager.clearQueue()
                } label: {
                    Text("Clear")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .disabled(queueManager.items.isEmpty)
                .help("Clear all items (⌃X)")
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

struct QueueItemRow: View {
    let item: ClipboardItem
    let index: Int
    let isOldest: Bool
    @ObservedObject var queueManager: QueueManager
    @State private var isHovering = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Content preview
            VStack(alignment: .leading, spacing: 4) {
                Text(item.shortPreview)
                    .lineLimit(2)
                    .font(.system(size: 12))
                    .foregroundColor(isOldest ? .primary : .secondary)
                
                HStack(spacing: 4) {
                    // Type icon
                    Image(systemName: iconName)
                        .font(.system(size: 10))
                        .foregroundColor(iconColor)
                    
                    Text(item.timeAgo)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if isOldest {
                        Text("• Next")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Delete button (shown on hover)
            if isHovering {
                Button(action: {
                    queueManager.removeItem(at: index)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Remove item")
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 1, dash: [4, 2])
                )
                .foregroundColor(isOldest ? .blue.opacity(0.5) : .secondary.opacity(0.3))
        )
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovering ? Color(NSColor.selectedControlColor).opacity(0.2) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var iconName: String {
        switch item.type {
        case .text:
            return "doc.text"
        case .url:
            return "link"
        case .other:
            return "doc"
        }
    }
    
    private var iconColor: Color {
        switch item.type {
        case .text:
            return .blue
        case .url:
            return .green
        case .other:
            return .gray
        }
    }
}
