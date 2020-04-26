extension UIFont {
    static func registerFont(bundle: Bundle, fontFileName: String, fontExtension: String) {
        guard let fontURL = bundle.url(forResource: fontFileName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontFileName)")
        }

        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontFileName)")
        }

        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print("Error registering font: maybe it was already registered.")
            return
        }
    }
}

public extension UIFont {

    struct FontFile {
        let name: String
        let fileName: String
        let ext: String
    }

    enum CustomFonts: CaseIterable {
        case GilroyExtrabold

        var value: FontFile {
            switch self {
            case .GilroyExtrabold:
                return FontFile(name: "Gilroy", fileName: "Gilroy-ExtraBold", ext: "otf")
            }
        }
    }
    // Lazy var instead of method so it's only ever called once per app session.
    static func loadFonts(for bundle: Bundle) {
      let fonts = CustomFonts.allCases.map { $0.value }
      for font in fonts {
        registerFont(bundle: bundle, fontFileName: font.fileName, fontExtension: font.ext)
      }
    }
}
