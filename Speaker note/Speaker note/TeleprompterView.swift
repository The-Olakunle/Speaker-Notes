import SwiftUI

struct TeleprompterView: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black)
    }
}
