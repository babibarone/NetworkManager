import Foundation

class ExampleService {
    private let networkManager: NetworkManager = .shared
    
    func getData(completion: @escaping (Result<Token, Error>) -> ()) {
        let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/corabank/desafio-ios/master/api/auth.js")!)
        networkManager.call(with: request) { result in
            completion(result)
        }
    }
}
