import UIKit

class ViewController: UIViewController {
    private let service: ExampleService = ExampleService()

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    private func getData() {
        service.getData { result in
            switch result {
            case let .success(data):
                print(data)
            case let .failure(error):
                print(error)
            }
        }
    }
}

"https://medium.com/@joseph.aberasturi/creating-a-network-manager-for-ios-mobile-applications-bc1b74c016f7"
