//

import SwiftUI

struct ContentDetailView: View {
    let photo: PhotoItem
    
    var body: some View {
        ScrollView {
            VStack {
                Button(action: {
                    UIApplication.shared.open(photo.link)
                }, label: {
                    AsyncImage(url: URL(string: photo.media.m)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                })
                Spacer()
                
                ZStack {
                    photoInfoSection(for: photo)
                        .foregroundStyle(.black)
                }
                .padding(8)
            }
        }
        .navigationTitle(photo.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: photo.link)
                    .accessibilityLabel("Share")
            }
        }
    }
    
    @ViewBuilder
    private func photoInfoSection(for photo: PhotoItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(title: "Title", value: photo.title)
            infoRow(title: "Description", value: photo.description, includesHTML: true)
            infoRow(title: "Author", value: photo.author)
            infoRow(title: "Size", value: "w:\(photo.size?.width ?? 0) h:\(photo.size?.height ?? 0)")
            infoRow(title: "Published", value: formattedDate(photo.dateTaken))
        }
        .padding(8)
        .background(Color.secondary.opacity(0.2))
        .foregroundStyle(.foreground)
        .cornerRadius(8)
    }
    
    private func infoRow(title: String, value: String, includesHTML: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            if includesHTML {
                HTMLText(text: value, font: .systemFont(ofSize: 17), tintColor: UIColor(.primary), linkColor: UIColor(Color.accentColor))
                    .accessibilityHidden(true)
            } else {
                Text(value)
                    .font(.body)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityHidden(false)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityAddTraits(.isStaticText)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct HTMLText: UIViewRepresentable {
    let text: String
    let font: UIFont
    let tintColor: UIColor?
    let linkColor: UIColor?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        updateUIView(label, context: context)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        DispatchQueue.main.async {
            let data = Data(self.text.utf8)
            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                attributedString.addAttributes([.foregroundColor: self.tintColor ?? UIColor(.primary)], range: NSRange(location: 0, length: attributedString.length))
                
                if let linkColor = self.linkColor {
                    attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
                        if value != nil {
                            attributedString.removeAttribute(.link, range: range)
                            
                            attributedString.addAttributes([
                                .foregroundColor: linkColor,
                                .underlineStyle: [],
                                .underlineColor: linkColor
                            ], range: range)
                        }
                    }
                }
                
                uiView.attributedText = attributedString
            }
            
            uiView.font = self.font
        }
    }
}


#Preview {
    ContentDetailView(photo: PhotoItem.sample)
}
