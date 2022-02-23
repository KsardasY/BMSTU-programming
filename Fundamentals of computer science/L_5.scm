(load "unit-test.scm")
(define ie (interaction-environment))
(define signs '(+ - * / mod))
(define logic '(= > <))


(define (member? xs x)
  (and (not (null? xs)) (or (equal? x (car xs)) (member? (cdr xs) x))))


(define (word-index word program index) ; поиск индекса слова
  (if (< index (vector-length program))
      (if (equal? (vector-ref program index) word)
          index
          (word-index word program (+ index 1)))
      #f))


(define (action-execute aliases action stack)
  (let ((aliased-action (assoc action aliases)))
    (if aliased-action
        (let ((aliased-action (cadr aliased-action)))
          (eval (list (car aliased-action)
                      (list (cadr aliased-action) (list 'quote stack))
                      (list (caddr aliased-action) (list 'quote stack))) ie))
        (eval (list action (cadr stack) (car stack)) ie))))


(define (math_act action stack) ; математические вычисления
  (define aliases (list (list 'mod '(remainder cadr car))))
  (cons (action-execute aliases action stack) (cddr stack)))


(define (logic_act action stack) ; логические сравнения
  (cons (if (action-execute '() action stack) -1 0) (cddr stack)))


(define (interpret program init-stack)
  (let interpreter ((index 0) (stack init-stack) (return-stack '()) (definitions '()))
    (if (= (vector-length program) index)
        stack
        (let ((word (vector-ref program index)))
          (cond
            ((number? word) (interpreter (+ index 1) (cons word stack) return-stack definitions))
            ((member? signs word) (interpreter (+ index 1) (math_act word stack) return-stack definitions))
            ((member? logic word) (interpreter (+ index 1) (logic_act word stack) return-stack definitions))
            ((equal? word 'not) (interpreter (+ index 1) (cons (if (= (car stack) -1) 0 -1) (cdr stack)) return-stack definitions))
            ((equal? word 'neg) (interpreter (+ index 1) (cons (- (car stack)) (cdr stack)) return-stack definitions))
            ((equal? word 'and) (interpreter (+ index 1) (cons (if (and (= (car stack) -1) (= (cdr stack) -1)) -1 0) (cddr stack)) return-stack definitions))
            ((equal? word 'or) (interpreter (+ index 1) (cons (if (or (= (car stack) -1) (= (cdr stack) -1)) -1 0) (cddr stack)) return-stack definitions))
            ((equal? word 'drop) (interpreter (+ index 1) (cdr stack) return-stack definitions))
            ((equal? word 'swap) (interpreter (+ index 1) (append (list (cadr stack) (car stack)) (cddr stack)) return-stack definitions))
            ((equal? word 'dup) (interpreter (+ index 1) (cons (car stack) stack) return-stack definitions))
            ((equal? word 'over) (interpreter (+ index 1) (cons (cadr stack) stack) return-stack definitions))
            ((equal? word 'rot) (interpreter (+ index 1) (append (list (caddr stack) (cadr stack) (car stack)) (cdddr stack)) return-stack definitions))
            ((equal? word 'depth) (interpreter (+ index 1) (cons (length stack) stack) return-stack definitions))
            ((equal? word 'define) (interpreter (+ (word-index 'end program index) 1) stack return-stack (cons (list (vector-ref program (+ index 1)) (+ index 2)) definitions)))
            ((member? '(exit end) word) (interpreter (car return-stack) stack (cdr return-stack) definitions))
            ((equal? word 'if) (if (word-index 'else program index)
                                   (interpreter (if (zero? (car stack)) (+ (word-index 'else program index) 1) (+ index 1)) (cdr stack) return-stack definitions)
                                   (interpreter (if (zero? (car stack)) (+ (word-index 'endif program index) 1) (+ index 1)) (cdr stack) return-stack definitions)
                                   ))
            ((equal? word 'else) (if (zero? (car stack))
                                     (interpreter (+ index 1) (cdr stack) return-stack definitions)
                                     (interpreter (+ (word-index 'endif program index) 1) stack return-stack definitions)))
            ((equal? word 'endif) (interpreter (+ index 1) stack return-stack definitions))
            ((equal? word 'while) (if (zero? (car stack))
                                      (interpreter (+ (word-index 'wend program index) 1) (cdr stack) return-stack definitions)
                                      (interpreter (+ index 1) (cdr stack) (cons index return-stack) definitions)))
            ((equal? word 'wend) (interpreter (car return-stack) stack (cdr return-stack) definitions))
            ((equal? word 'repeat) (interpreter (+ index 1) stack (cons index return-stack) definitions))
            ((equal? word 'until) (interpreter (if (zero? (car stack)) (+ index 1) (car return-stack)) stack (cdr return-stack) definitions))
            (else (interpreter (cadr (assoc word definitions)) stack (cons (+ index 1) return-stack) definitions)))))))


(define inter-tests
  (list
   (test (interpret #(   define abs
                          dup 0 <
                          if neg endif
                          end
                          9 abs
                          -9 abs      ) (quote ())) '(9 9))
   (test (interpret #(   define =0? dup 0 = end
                          define <0? dup 0 < end
                          define signum
                          =0? if exit endif
                          <0? if drop -1 exit endif
                          drop
                          1
                          end
                          0 signum
                          -5 signum
                          10 signum       ) (quote ())) '(1 -1 0))
   (test (interpret #(   define -- 1 - end
                          define =0? dup 0 = end
                          define =1? dup 1 = end
                          define factorial
                          =0? if drop 1 exit endif
                          =1? if drop 1 exit endif
                          dup --
                          factorial
                          *
                          end
                          0 factorial
                          1 factorial
                          2 factorial
                          3 factorial
                          4 factorial     ) (quote ())) '(24 6 2 1 1))
   (test (interpret #(   define =0? dup 0 = end
                          define =1? dup 1 = end
                          define -- 1 - end
                          define fib
                          =0? if drop 0 exit endif
                          =1? if drop 1 exit endif
                          -- dup
                          -- fib
                          swap fib
                          +
                          end
                          define make-fib
                          dup 0 < if drop exit endif
                          dup fib
                          swap --
                          make-fib
                          end
                          10 make-fib     ) (quote ())) '(0 1 1 2 3 5 8 13 21 34 55))
   (test (interpret #(   define =0? dup 0 = end
                          define gcd
                          =0? if drop exit endif
                          swap over mod
                          gcd
                          end
                          90 99 gcd
                          234 8100 gcd    ) '()) '(18 9))
   ))

(run-tests inter-tests)
