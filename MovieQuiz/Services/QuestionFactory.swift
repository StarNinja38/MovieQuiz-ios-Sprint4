import Foundation

final class QuestionFactory: QuestionFactoryProtocol {

    // MARK: - Properties

    weak var delegate: QuestionFactoryDelegate?

    // MARK: - Private Properties

    private var currentIndex = 0
    private lazy var shuffledQuestions: [QuizQuestion] = questions.shuffled()

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]

    // MARK: - Initializer

    init(delegate: QuestionFactoryDelegate? = nil) {
        self.delegate = delegate
    }

    // MARK: - QuestionFactoryProtocol

    func requestNextQuestion() {
        guard currentIndex < shuffledQuestions.count else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = shuffledQuestions[currentIndex]
        currentIndex += 1
        delegate?.didReceiveNextQuestion(question: question)
    }

    func resetQuestions() {
        shuffledQuestions = questions.shuffled()
        currentIndex = 0
    }
}
