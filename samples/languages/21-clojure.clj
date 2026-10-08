(ns languagetour.clojure
  "Clojure language tour.

  Covers namespaces, immutable data, destructuring, protocols,
  records, multimethods, atoms, threading macros and transducers."
  (:require [clojure.string :as str]
            [clojure.set :as set]))

;; Severity levels for a log line.
(def ^:const severities {:debug 1 :info 2 :warning 3 :error 4})

(defprotocol Repository
  "Generic repository contract."
  (find-by-id [this id] "Returns the entity or nil.")
  (watch-all [this limit] "Returns a lazy sequence of entities."))

(defrecord LogEntry [message severity tags]
  Object
  (toString [_]
    (format "[%s] %s (%d tags)" (name severity) message (count tags))))

(defn make-entry
  "Creates a log entry.

  Arguments:
    message  - the human readable text
    severity - one of the keys of `severities`
    tags     - optional labels

  Throws `IllegalArgumentException` when message is blank."
  [message & {:keys [severity tags] :or {severity :info tags []}}]
  (when (str/blank? message)
    (throw (IllegalArgumentException. "message required")))
  (->LogEntry message severity tags)) ; inline comment

(defrecord LogRepository [store]
  Repository
  (find-by-id [_ id] (get @store id))
  (watch-all [_ limit] (take limit (vals @store))))

(defmulti describe (fn [_ severity] severity))
(defmethod describe :error [_ _] "failing")
(defmethod describe :default [count _]
  (cond
    (zero? count) "empty"
    (> count 100) "busy"
    :else "ok"))

(defn recent
  "Most recent severe messages, via a threading macro."
  [repo take-n]
  (->> (vals @(:store repo))
       (filter #(>= (severities (:severity %)) 3))
       (map :message)
       (take take-n)
       (into [])))

(comment
  (let [repo (->LogRepository (atom {1 (make-entry "hello" :severity :error)}))]
    [(find-by-id repo 1)
     (recent repo 5)
     (describe 0 :debug)]))
