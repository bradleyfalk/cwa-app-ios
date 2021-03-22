//
// 🦠 Corona-Warn-App
//

import Foundation

protocol ReuseIdentifierProviding {

	static var reuseIdentifier: String { get }

}

extension ReuseIdentifierProviding {

	static var reuseIdentifier: String {
		String(describing: self)
	}

}
