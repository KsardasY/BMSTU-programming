(define-syntax test
  (syntax-rules ()
    ((_ fx res)
     (let ((q 'fx) (ans res))
       (list q res)))))


(define (run-test x)
  (display (car x))
  (let ((returned (eval (car x) (interaction-environment))) (expected (cadr x)))
    (if (equal? returned expected)
        (begin
        (display " ok\n")
        #t)
        (begin
          (display " fail\n")
         (display "  Expected:")
          (display expected)
          (display "\n  Returned:")
          (display returned)
          (newline)
          #f))))


(define (run-tests l)
  (define (loop b a)
    (if (null? a)
        b
        (loop (and (run-test (car a)) b) (cdr a))))
  (loop #t l))
