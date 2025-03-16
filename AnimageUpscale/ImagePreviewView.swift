import SwiftUI

struct ImagePreviewView: View {
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    var body: some View {
        if let image = NSImage(contentsOfFile: imagePath) {
            GeometryReader { geometry in
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(15)
                    .shadow(radius: 5)
            }
        } else {
            VStack {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                Text("Failed to load image")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}
