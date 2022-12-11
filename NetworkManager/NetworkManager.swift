import Foundation

enum NetworkError: Error {
    case timedOut
    case connectionFailure
    case noData
    case invalidURL
    case invalidResponse
}

class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    private let timeout: Double = 5
    private let retryAfterSeconds: Double = 3.0
    private let maxRetries: Int = 5
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func call<T:Decodable>(with request: URLRequest, attempt: Int = 0, completion: @escaping (Result<T, Error>) -> ()) {
        var inProgress: Bool = true
        
        let task = session.dataTask(with: request) { data, response, error in
            inProgress = false
            
            if error == nil {
                if let data = data {
                    if let datas = try? JSONDecoder().decode(T.self, from: data) {
                        completion(.success(datas))
                    } else {
                        completion(.failure(NetworkError.invalidResponse))
                    }
                } else {
                    completion(.failure(NetworkError.noData))
                }
            } else {
                
                //check if should retry again
                if attempt < self.maxRetries {
                    
                    //retry after timeout
                    self.setTimeout(self.retryAfterSeconds) {
                        self.call(with: request, attempt: attempt + 1, completion: completion)
                    }
                } else {
                    
                    //pass back failure
                    completion(.failure(NetworkError.connectionFailure))
                }
            }
        }
        
        task.resume()
        
        //cancel request if taking to long
        setTimeout(timeout) {
            if inProgress {
                task.cancel()
                
                //attempt retry
                if attempt < self.maxRetries {
                    self.call(with: request, attempt: attempt + 1, completion: completion)
                } else {
                    //pass back failure
                    completion(.failure(NetworkError.timedOut))
                }
            }
        }
    }
    
    private func setTimeout(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
