import SwiftUI
import WebKit

struct HelpView: View {
    @State private var selectedTab = 0
    @State private var navigateToPreview = false

    private let tabs = ["Intro", "Tips", "Thanks"]
    private let files = ["help-intro", "help-tips", "help-thanks"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.2, blue: 0.2),
                         Color(red: 0.0, green: 0.0, blue: 0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Picker("Page", selection: $selectedTab) {
                    ForEach(0..<tabs.count, id: \.self) { i in
                        Text(tabs[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                WebViewRepresentable(htmlFile: files[selectedTab])
                    .id(selectedTab)

                if selectedTab == 0 {
                    Button("Try Sample Puzzle") { navigateToPreview = true }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom)
                }
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPreview) {
            if let img = UIImage(named: "sample-puzzle") {
                PreviewView(image: img)
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let htmlFile: String

    func makeUIView(context: Context) -> WKWebView { WKWebView() }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let path = Bundle.main.path(forResource: htmlFile, ofType: "html") {
            webView.loadFileURL(URL(fileURLWithPath: path), allowingReadAccessTo: URL(fileURLWithPath: path))
        }
    }
}
