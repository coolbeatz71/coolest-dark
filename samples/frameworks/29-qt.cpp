/**
 * @file 29-qt.cpp
 * @brief Qt framework tour.
 *
 * Covers QObject, signals and slots, properties, models,
 * layouts, event handling and the meta-object system.
 */

#include <QAbstractListModel>
#include <QApplication>
#include <QLineEdit>
#include <QListView>
#include <QPushButton>
#include <QString>
#include <QVBoxLayout>
#include <QVector>
#include <QWidget>

namespace framework_tour {

/// An immutable value type.
struct Article {
    int id{};
    QString title;
    int likeCount{};
};

/**
 * A list model exposing articles to the view layer.
 */
class ArticleModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles { TitleRole = Qt::UserRole + 1, LikeCountRole };
    Q_ENUM(Roles)

    explicit ArticleModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        return parent.isValid() ? 0 : static_cast<int>(m_articles.size());
    }

    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid() || index.row() >= m_articles.size()) {
            return {};
        }

        const Article &article = m_articles.at(index.row());
        switch (role) {
        case Qt::DisplayRole:
        case TitleRole:
            return article.title;
        case LikeCountRole:
            return article.likeCount;  // inline comment
        default:
            return {};
        }
    }

    [[nodiscard]] QHash<int, QByteArray> roleNames() const override {
        return {{TitleRole, "title"}, {LikeCountRole, "likeCount"}};
    }

public slots:
    void addArticle(const QString &title) {
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_articles.append(Article{rowCount() + 1, title, 0});
        endInsertRows();
        emit countChanged();
    }

signals:
    void countChanged();

private:
    QVector<Article> m_articles;
};

class MainWindow : public QWidget {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr) : QWidget(parent) {
        auto *layout = new QVBoxLayout(this);
        auto *input = new QLineEdit(this);
        auto *button = new QPushButton(tr("Add"), this);
        auto *view = new QListView(this);

        input->setPlaceholderText(tr("Article title…"));
        view->setModel(&m_model);

        layout->addWidget(input);
        layout->addWidget(button);
        layout->addWidget(view);

        // Modern connect syntax with a lambda.
        connect(button, &QPushButton::clicked, this, [this, input]() {
            if (!input->text().trimmed().isEmpty()) {
                m_model.addArticle(input->text().trimmed());
                input->clear();
            }
        });

        connect(&m_model, &ArticleModel::countChanged, this, &MainWindow::updateTitle);
    }

private slots:
    void updateTitle() { setWindowTitle(tr("Articles (%1)").arg(m_model.rowCount())); }

private:
    ArticleModel m_model;
};

}  // namespace framework_tour
