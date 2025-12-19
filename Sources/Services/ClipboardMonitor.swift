import Foundation
import AppKit

class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int
    private let pasteboard = NSPasteboard.general
    private weak var queueManager: QueueManager?
    
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        self.lastChangeCount = pasteboard.changeCount
    }
    
    func startMonitoring() {
        // Sync with current clipboard state to avoid picking up old changes
        lastChangeCount = pasteboard.changeCount
        
        // Check clipboard every 0.5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        print("📋 Clipboard monitoring started")
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        print("📋 Clipboard monitoring stopped")
    }
    
    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount
        
        // Check if clipboard has changed
        guard currentChangeCount != lastChangeCount else {
            return
        }
        
        lastChangeCount = currentChangeCount
        
        // Try to get string content
        guard let content = pasteboard.string(forType: .string),
              !content.isEmpty else {
            return
        }
        
        // Add to queue
        let item = ClipboardItem(content: content, type: determineType(content))
        queueManager?.addItem(item)
        
        print("📋 Added to queue: \(item.shortPreview)")
    }
    
    private func determineType(_ content: String) -> ClipboardItem.ItemType {
        // Simple URL detection
        if content.hasPrefix("http://") || content.hasPrefix("https://") {
            return .url
        }
        return .text
    }
}
