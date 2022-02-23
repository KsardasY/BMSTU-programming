;#1 trace
(display "#1 trace\n")


(define-syntax trace-ex
  (syntax-rules ()
    ((_ x)
     (let ((res x))
       (display 'x)
       (display " => ")
       (display res)
       (newline)
       res))))


(define (zip . xss)
  (if (or (null? xss)
          (null? (trace-ex (car xss))))
      '()
      (cons (map car xss)
            (apply zip (map cdr (trace-ex xss))))))


(zip '(1 2 3) '(one two three))


;#2 test
(display "\n#2 test\n")


(define (signum x)
  (cond
    ((< x 0) -1)
    ((= x 0)  1)
    (else     1)))


(load "unit-test.scm")


(define the-tests
  (list (test (signum -2) -1)
        (test (signum  0)  0)
        (test (signum  2)  1)))


(run-tests the-tests)


(define expt-tests
  (list(test (expt 2 3) 8)
       (test (expt 3 -2) 1/9)
       (test (expt -6 3) -216)))


(run-tests expt-tests)


;#3 index/insert
(display "\n#3 ref\n")


(define (to-list x)
  (cond
    ((string? x) (string->list x))
    ((vector? x) (vector->list x))
    ((list? x) x)))


(define (index c ind)
  (let ((a (to-list c)) (i ind))


    (define (loop i a)
          (if (= i 0)
              (car a)
              (loop (- i 1) (cdr a))))

    
    (if (or (not (number? i)) (> i (- (length a) 1)) (< i 0))
        #f
        (loop i a))))


(display "(index '(1 2 3) 1) -> ")
(index '(1 2 3) 1)
(display "(index #(1 2 3) 1) -> ")
(index #(1 2 3) 1)
(display "(index \"(1 2 3)\" 1) -> ")
(index "123" 1)
(display "(index \"(1 2 3)\" 3) -> ")
(index "123" 3)


(define (insert c ind el)
  (define (loop i x b a)
          (if (= i 0)
              (append b (cons x a))
              (loop (- i 1) x (append b (list (car a))) (cdr a))))

  
  (let ((a (to-list c)) (i ind))
    (cond ((or (> i (length a)) (not (number? i)) (< i 0) (and (string? c) (not (string? el)) (not (char? el)))) #f)
          ((list? c) (loop i el '() a))
          ((string? c) (list->string (loop i el '() a)))
          ((vector? c) (list->vector (loop i el '() a)))
          (else #f))))


(display "(insert '(1 2 3) 1 0) -> ")
(insert '(1 2 3) 1 0)
(display "(insert #(1 2 3) 1 0) -> ")
(insert #(1 2 3) 1 0)
(display "(insert #(1 2 3) 1 #\0) -> ")
(insert #(1 2 3) 1 #\0)
(display "(insert \"123\" 1 #\\0) -> ")
(insert "123" 1 #\0)
(display "(insert \"123\" 1 0) -> ")
(insert "123" 1 0)
(display "(insert \"123\" 3 #\\4) -> ")
(insert "123" 3 #\4)
(display "(insert \"123\" 5 #\\4) -> ")
(insert "123" 5 #\4)


;#4
(display "\n#4 factorize\n")


(define-syntax factorize
  (syntax-rules (expt)
    ((_ '(- (expt x 2) (expt y 2)))
     '(* (- x y) (+ x y)))
    ((_ '(- (expt x 3) (expt y 3)))
     '(* (- x y) (+ (expt x 2) (* x y) (expt y 2))))
    ((_ '(+ (expt x 3) (expt y 3)))
     '(* (+ x y) (+ (- (expt x 2) (* x y)) (expt y 2))))))


(display "(factorize '(- (expt x 2) (expt y 2))) -> ")
(factorize '(- (expt x 2) (expt y 2)))
(display "(factorize '(- (expt (+ first 1) 2) (expt (- second 1) 2))) -> ")
(factorize '(- (expt (+ first 1) 2) (expt (- second 1) 2)))
(display "(eval (list (list 'lambda '(x y) (factorize '(- (expt x 2) (expt y 2)))) 1 2) (interaction-environment)) -> ")
(eval (list (list 'lambda '(x y) (factorize '(- (expt x 2) (expt y 2)))) 1 2) (interaction-environment))
