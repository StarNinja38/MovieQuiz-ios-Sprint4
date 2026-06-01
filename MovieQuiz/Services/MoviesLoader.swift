import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {

    // MARK: - NetworkClient

    private let networkClient: NetworkRouting
    private let decoder = JSONDecoder()

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    // MARK: - URL

    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    // MARK: - MoviesLoading

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try decoder.decode(MostPopularMovies.self, from: data)
                    guard mostPopularMovies.errorMessage.isEmpty else {
                        handler(.failure(NetworkError.apiError(mostPopularMovies.errorMessage)))
                        return
                    }
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

// MARK: - NetworkError

private enum NetworkError: LocalizedError {
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        }
    }
}
