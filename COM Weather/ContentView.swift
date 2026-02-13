import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showSecondView = false
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
            VStack {
                Image("banner1")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(60)
                    .padding(.top, 30)
                
                Text("Welcome to College of Marin Weather App!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(8)
                    .foregroundColor(Color.white)
                
                Image("sunny")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(90)
                    .frame(width: 300, height: 300)
                    .shadow(radius: 10)
                    .padding(.top, -40)
                
                Text("Currently Sunny!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(-20)
                    .foregroundColor(Color.white)
                
                Spacer()
                
                Button(action: {
                    showSecondView = true
                }) {
                    Text("Check Live Data!")
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(40)
                }
                .padding(.top, 40)
                .sheet(isPresented: $showSecondView) {
                    SecondViewControllerWrapper()
                }
            }
            .padding(20)
        }
    }
}

struct SecondViewControllerWrapper: View {
    var body: some View {
        UIKitViewControllerRepresentable()
    }
}

struct UIKitViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return SecondViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .darkGray
        let label = UILabel()
                label.text = "Live COM Weather"
                label.textAlignment = .center
        let labelWidth : CGFloat = 200
        let parentWidth: CGFloat = self.view.frame.size.width
        
        let xPosition = (parentWidth - labelWidth) / 2
                label.frame = CGRect(x: xPosition, y: 100, width: 200, height: 50)
                label.textAlignment = .center
                self.view.addSubview(label)
                
                // Add the image view with square frame
                let imageView = UIImageView(image: UIImage(named: "banner1"))
                imageView.contentMode = .scaleAspectFill  // Use .scaleAspectFill to ensure it fills the frame
                
                // Make the frame square (adjust the width and height as needed)
                let imageSize: CGFloat = 300  // Set a fixed size for the image (square)
                imageView.frame = CGRect(x: (view.frame.width - imageSize) / 2, y: 200, width: imageSize, height: imageSize)
                
                // Apply rounded corners (corner radius should be half of the size)
                imageView.layer.cornerRadius = imageSize / 2
                imageView.clipsToBounds = true  // Ensure the image is clipped within the rounded corners
                
                self.view.addSubview(imageView)
    }
}

#Preview {
    ContentView()
}
