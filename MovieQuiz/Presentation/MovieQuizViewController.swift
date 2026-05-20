import UIKit

// MARK: - View Controller

final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    // MARK: - Private Properties

    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?

    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: ResultAlertPresenter?
    private var statisticService: StatisticServiceProtocol?

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20

        alertPresenter   = ResultAlertPresenter()
        statisticService = StatisticService()

        setupActivityIndicator()

        let factory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory = factory

        showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - IBActions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }

    // MARK: - Private Methods

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }

        alertPresenter?.show(in: self, model: model)
    }

    private func handleAnswer(_ userAnswer: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = userAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled  = isEnabled
        yesButton.isEnabled = isEnabled
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image             = step.image
        textLabel.text              = step.question
        counterLabel.text           = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonsEnabled(true)
    }

    private func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)

        let gamesCount    = statisticService?.gamesCount ?? 0
        let bestGame      = statisticService?.bestGame
        let totalAccuracy = statisticService?.totalAccuracy ?? 0

        let bestGameInfo: String
        if let best = bestGame {
            bestGameInfo = "\(best.correct)/\(best.total) (\(best.date.dateTimeString))"
        } else {
            bestGameInfo = "Нет данных"
        }

        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGameInfo)
        Средняя точность: \(String(format: "%.2f", totalAccuracy))%
        """

        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers       = 0
            self.questionFactory?.resetQuestions()
            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter?.show(in: self, model: model)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }

        setButtonsEnabled(false)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth   = 8
        imageView.layer.borderColor   = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "",
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel   = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.show(quiz: viewModel)
        }
    }
}
