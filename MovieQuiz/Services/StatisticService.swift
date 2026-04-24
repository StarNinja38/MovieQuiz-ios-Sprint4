import Foundation

final class StatisticService: StatisticServiceProtocol {

    // MARK: - Private Properties

    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

    // MARK: - StatisticServiceProtocol

    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total   = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date    = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total,   forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date,    forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        let asked = totalQuestionsAsked
        guard asked > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(asked) * 100
    }

    func store(correct count: Int, total amount: Int) {
        gamesCount          += 1
        totalCorrectAnswers += count
        totalQuestionsAsked += amount

        let current = GameResult(correct: count, total: amount, date: Date())
        if gamesCount == 1 || current.isBetterThan(bestGame) {
            bestGame = current
        }
    }

    // MARK: - Private computed properties

    private var totalCorrectAnswers: Int {
        get { storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }

    private var totalQuestionsAsked: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }
}
