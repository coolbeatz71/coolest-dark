;; =============================================================
;; WebAssembly Text Format (WAT) language tour
;;
;; Covers modules, types, imports/exports, memory, tables, globals,
;; functions, locals, control flow, loops and the stack machine.
;; =============================================================

(module $language_tour

  ;; ---- imports ------------------------------------------------
  (import "env" "log" (func $log (param i32 i32)))
  (import "env" "memory" (memory $mem 1 16))

  ;; ---- type declarations --------------------------------------
  (type $describe_t (func (param i32 i32) (result i32)))
  (type $predicate_t (func (param i32) (result i32)))

  ;; ---- globals ------------------------------------------------
  (global $SEVERITY_ERROR i32 (i32.const 4))
  (global $counter (mut i32) (i32.const 0))

  ;; ---- data segment -------------------------------------------
  (data (i32.const 0) "ok\00busy\00empty\00failing\00")

  ;; ---- function table for indirect calls ----------------------
  (table $fns 2 funcref)
  (elem (i32.const 0) $is_severe $is_quiet)

  ;; Returns 1 when the rank is warning or above.
  (func $is_severe (type $predicate_t) (param $rank i32) (result i32)
    local.get $rank
    i32.const 3
    i32.ge_s)

  (func $is_quiet (type $predicate_t) (param $rank i32) (result i32)
    local.get $rank
    i32.const 2
    i32.le_s)

  ;; -------------------------------------------------------------
  ;; describe(count, severity) -> offset into the data segment
  ;;   0 = "ok", 3 = "busy", 8 = "empty", 14 = "failing"
  ;; -------------------------------------------------------------
  (func $describe (export "describe") (type $describe_t)
    (param $count i32) (param $severity i32) (result i32)
    (local $result i32)

    ;; if count == 0 -> "empty"
    (if (i32.eqz (local.get $count))
      (then
        (local.set $result (i32.const 8))
        (return (local.get $result))))

    ;; if severity == ERROR -> "failing"
    (if (i32.eq (local.get $severity) (global.get $SEVERITY_ERROR))
      (then (return (i32.const 14))))

    ;; if count > 100 -> "busy" else "ok"
    (select
      (i32.const 3)
      (i32.const 0)
      (i32.gt_s (local.get $count) (i32.const 100))))

  ;; Counts severe entries with a loop and an indirect call.
  (func $count_severe (export "count_severe")
    (param $ptr i32) (param $len i32) (result i32)
    (local $i i32)
    (local $total i32)

    (block $break
      (loop $continue
        (br_if $break (i32.ge_u (local.get $i) (local.get $len)))

        (if (call_indirect (type $predicate_t)
              (i32.load8_u (i32.add (local.get $ptr) (local.get $i)))
              (i32.const 0))                      ;; table index 0 = $is_severe
          (then
            (local.set $total (i32.add (local.get $total) (i32.const 1)))))

        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $continue)))

    (global.set $counter (local.get $total))
    (local.get $total))

  (export "memory" (memory $mem))
  (start $bump)

  (func $bump
    (global.set $counter (i32.add (global.get $counter) (i32.const 1)))))
