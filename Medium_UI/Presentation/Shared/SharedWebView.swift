#if os(iOS)
import UIKit
import WebKit
#elseif os(macOS)
import AppKit
@preconcurrency import WebKit
#endif
import SwiftUI

struct IframeView: View {
    let paragraph: Paragraph
    
    var body: some View {
        if let src = paragraph.iframe?.mediaResource.iframeSrc {
            SharedWebView(urlString: src)
                .frame(height: 400)
                .padding(.vertical, 8)
        }
    }
}

#if os(iOS)
struct SharedWebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let scrollView = webView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadURL(in: webView)
    }
    
    typealias UIViewType = WKWebView
}
#elseif os(macOS)
struct SharedWebView: NSViewRepresentable {
    let urlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let scrollView = webView.subviews.first(where: { $0 is NSScrollView }) as? NSScrollView {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
        }
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        loadURL(in: webView)
    }
    
    typealias NSViewType = WKWebView
}
#endif

extension SharedWebView {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func loadURL(in webView: WKWebView) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SharedWebView
        
        init(_ parent: SharedWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .other {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}
