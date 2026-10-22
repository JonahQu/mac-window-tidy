import AppKit
import ApplicationServices
let arguments=CommandLine.arguments
if arguments.count < 2 {
    print("Usage: swift close_selected_windows.swift targets.json [--apply]")
    exit(1)
}
let rawTargets=try JSONDecoder().decode([String:[String]].self, from:Data(contentsOf:URL(fileURLWithPath:arguments[1])))
let targets=rawTargets.mapValues { Set($0) }
let apply=arguments.contains("--apply")
func windows(_ app:AXUIElement)->[AXUIElement]{var v:CFTypeRef?;AXUIElementCopyAttributeValue(app,kAXWindowsAttribute as CFString,&v);return v as? [AXUIElement] ?? []}
func title(_ w:AXUIElement)->String{var v:CFTypeRef?;AXUIElementCopyAttributeValue(w,kAXTitleAttribute as CFString,&v);return v as? String ?? ""}
var results:[[String:Any]]=[]
for a in NSWorkspace.shared.runningApplications {
 guard let id=a.bundleIdentifier,let allowed=targets[id] else {continue}
 let app=AXUIElementCreateApplication(a.processIdentifier);AXUIElementSetMessagingTimeout(app,2)
 let before=windows(app)
 for w in before where allowed.contains(title(w)) {
  let name=title(w)
  var modified:CFTypeRef?;AXUIElementCopyAttributeValue(w,"AXDocumentEdited" as CFString,&modified)
  var sheets:CFTypeRef?;AXUIElementCopyAttributeValue(w,"AXSheets" as CFString,&sheets)
  if (modified as? Bool)==true || !(sheets as? [AXUIElement] ?? []).isEmpty {results.append(["app":id,"title":name,"result":"skipped_edit_or_sheet"]);continue}
  if !apply {results.append(["app":id,"title":name,"result":"would_close"]);continue}
  var close:CFTypeRef?
  guard AXUIElementCopyAttributeValue(w,kAXCloseButtonAttribute as CFString,&close) == .success,let raw=close else {continue}
  let button=unsafeBitCast(raw,to:AXUIElement.self)
  let err=AXUIElementPerformAction(button,kAXPressAction as CFString)
  Thread.sleep(forTimeInterval:0.25)
  let after=windows(app)
  results.append(["app":id,"pid":a.processIdentifier,"title":name,"action_error":err.rawValue,"title_absent_after": !after.contains(where:{title($0)==name}),"window_count_before":before.count,"window_count_after":after.count,"process_still_running": !a.isTerminated])
 }
}
let data=try JSONSerialization.data(withJSONObject:results,options:[.prettyPrinted,.sortedKeys])
print(String(data:data,encoding:.utf8)!)
