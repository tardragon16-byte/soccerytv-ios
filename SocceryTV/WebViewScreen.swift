//
//  WebViewScreen.swift
//  SocceryTV
//
//  Full-featured WKWebView with pull-to-refresh, progress bar,
//  navigation controls, and share functionality.
//

import SwiftUI
import WebKit

struct WebViewScreen: View {
    let url: URL
    @State private var webViewStore = WebViewStore()
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            WebViewWrapper(store: webViewStore, url: url)
                .ignoresSafeArea(edges: .bottom)

            // Progress bar
            if webViewStore.isLoading {
                ProgressView(value: webViewStore.estimatedProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#22c55e")))
                    .frame(height: 3)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    webViewStore.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!webViewStore.canGoBack)

                Button {
                    webViewStore.goForward()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!webViewStore.canGoForward)

                Spacer()

                Button {
                    webViewStore.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }

                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let currentURL = webViewStore.currentURL {
                ShareSheet(items: [currentURL])
            }
        }
    }
}

// MARK: - WebView Store (Observable State)
@Observable
class WebViewStore {
    var isLoading: Bool = false
    var estimatedProgress: Double = 0.0
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var currentURL: URL?
    var pageTitle: String = ""

    weak var webView: WKWebView?

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }
}

// MARK: - WebView UIKit Wrapper
struct WebViewWrapper: UIViewRepresentable {
    let store: WebViewStore
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true

        // Allow video to play in fullscreen
        config.preferences.isElementFullscreenEnabled = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color(hex: "#0f172a"))
        webView.scrollView.backgroundColor = UIColor(Color(hex: "#0f172a"))

        // Pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(Color(hex: "#22c55e"))
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl

        // KVO observers
        context.coordinator.observeWebView(webView)

        // Store reference
        store.webView = webView

        // Load
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No dynamic updates needed
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let store: WebViewStore
        private var observations: [NSKeyValueObservation] = []

        init(store: WebViewStore) {
            self.store = store
        }

        func observeWebView(_ webView: WKWebView) {
            observations = [
                webView.observe(\.isLoading) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.isLoading = wv.isLoading
                    }
                },
                webView.observe(\.estimatedProgress) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.estimatedProgress = wv.estimatedProgress
                    }
                },
                webView.observe(\.canGoBack) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.canGoBack = wv.canGoBack
                    }
                },
                webView.observe(\.canGoForward) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.canGoForward = wv.canGoForward
                    }
                },
                webView.observe(\.url) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.currentURL = wv.url
                    }
                },
                webView.observe(\.title) { [weak self] wv, _ in
                    DispatchQueue.main.async {
                        self?.store.pageTitle = wv.title ?? ""
                    }
                }
            ]
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            store.webView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sender.endRefreshing()
            }
        }

        // MARK: WKNavigationDelegate

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let url = navigationAction.request.url else {
                return .cancel
            }

            let host = url.host?.lowercased() ?? ""

            // Allow soccerytv.com and its subdomains
            if host.contains("soccerytv.com") {
                return .allow
            }

            // Allow known CDN / resource domains
            let allowedDomains = [
                "fonts.googleapis.com", "fonts.gstatic.com",
                "cdn.jsdelivr.net", "cdnjs.cloudflare.com",
                "pagead2.googlesyndication.com",
                "googletagmanager.com", "google-analytics.com",
                "connect.facebook.net", "facebook.com",
                "cloudflareinsights.com",
                "dlsuiapk.top", "soc-9fv.pages.dev", "archive.org"
            ]

            for domain in allowedDomains {
                if host.contains(domain) {
                    return .allow
                }
            }

            // Open external links in Safari
            if navigationAction.navigationType == .linkActivated {
                await UIApplication.shared.open(url)
                return .cancel
            }

            // Allow other resource loads (images, scripts, etc.)
            return .allow
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject CSS to hide elements not needed in app
            let hideCSS = """
            (function() {
                var style = document.createElement('style');
                style.textContent = '#official-bar { display: none !important; }';
                document.head.appendChild(style);
            })();
            """
            webView.evaluateJavaScript(hideCSS)
        }

        // MARK: WKUIDelegate

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle target="_blank" links
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
