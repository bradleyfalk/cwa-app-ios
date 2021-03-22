//
// 🦠 Corona-Warn-App
//

#if !RELEASE

protocol ConfigureableCell: ReuseIdentifierProviding {

	func configure<T>(cellViewModel: T)

}

#endif
