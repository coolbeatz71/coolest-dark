/**
 * @file 14-cpp.cpp
 * @brief C++ tour: templates, RAII, smart pointers, concepts, lambdas.
 */

#include <algorithm>
#include <concepts>
#include <memory>
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

namespace language_tour {

/// Severity levels for a log line.
enum class Severity : int { Debug, Info, Warning, Error };

/// Concept constraining identifier types.
template <typename T>
concept Identifier = std::integral<T> || std::convertible_to<T, std::string>;

/// An immutable value type.
struct LogEntry {
    std::string message;
    Severity severity{Severity::Info};
    std::vector<std::string> tags{};

    [[nodiscard]] std::string to_string() const {
        return "[" + std::to_string(static_cast<int>(severity)) + "] " + message;
    }
};

/**
 * Generic repository contract.
 *
 * @tparam T  the stored entity type
 * @tparam Id the identifier type
 */
template <typename T, Identifier Id>
class Repository {
public:
    virtual ~Repository() = default;
    virtual std::optional<T> find_by_id(const Id& id) const = 0;
};

class LogRepository final : public Repository<LogEntry, int> {
public:
    explicit LogRepository(std::unordered_map<int, LogEntry> store)
        : store_{std::move(store)} {}

    std::optional<LogEntry> find_by_id(const int& id) const override {
        if (auto it = store_.find(id); it != store_.end()) {
            return it->second;  // inline comment
        }
        return std::nullopt;
    }

    [[nodiscard]] std::vector<std::string> recent(std::size_t take) const {
        std::vector<std::string> out;
        for (const auto& [id, entry] : store_) {
            if (entry.severity >= Severity::Warning && out.size() < take) {
                out.push_back(entry.message);
            }
        }
        std::sort(out.begin(), out.end(), [](const auto& a, const auto& b) { return a < b; });
        return out;
    }

private:
    std::unordered_map<int, LogEntry> store_;
    std::unique_ptr<int> counter_{std::make_unique<int>(0)};
};

}  // namespace language_tour
