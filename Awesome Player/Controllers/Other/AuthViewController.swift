import UIKit
import WebKit

final class AuthViewController: UIViewController, WKNavigationDelegate {
	private let webView: WKWebView = {
		let prefs = WKWebpagePreferences()
		prefs.allowsContentJavaScript = true
		let config = WKWebViewConfiguration()
		config.defaultWebpagePreferences = prefs
		let webView = WKWebView(frame: .zero, configuration: config)
		return webView
	}()

	/// creating sign in url with all the needed attributes
	private var signInURL: URL {
		let base = Configuration.spotifyAuthBaseURL
		let clientIdString = "client_id=\(Configuration.spotifyClientID)"
		let scopesString = "scope=\(Configuration.APIScopes.replacingOccurrences(of: " ", with: "%20"))"
		let redirectURIString = "redirect_uri=\(Configuration.redirectURI)"
		let showDialogString = "show_dialog=TRUE"
		let string = "\(base)?response_type=code&\(clientIdString)&\(scopesString)&\(redirectURIString)&\(showDialogString)"
		return URL(string: string)!
	}

	var completionHandler: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		title = L10n.signIn

		webView.navigationDelegate = self
		view.addSubview(webView)

		webView.load(URLRequest(url: signInURL))
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		webView.frame = view.bounds
	}

	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		guard let url = webView.url else {
			return
		}

		let component = URLComponents(string: url.absoluteString)
		guard let code = component?.queryItems?.first(where: { $0.name == "code" })?.value else {
			return
		}

		webView.isHidden = true

		AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
			DispatchQueue.main.async {
				self?.navigationController?.popToRootViewController(animated: true)
				self?.completionHandler?(success)
			}
		}
	}
}
