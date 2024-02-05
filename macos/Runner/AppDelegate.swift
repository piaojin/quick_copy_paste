import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        mainFlutterWindow?.setFrame(NSRect(origin: mainFlutterWindow?.frame.origin ?? .zero, size: NSSize(width: 400, height: 450)), display: true, animate: true)
    }
}
