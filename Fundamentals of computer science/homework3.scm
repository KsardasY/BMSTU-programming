(load "unit-test.scm")
(define ie (interaction-environment))


(define (derivative x)
  (define (priority b x)
    (cond ((null? x) b)
          ((number? (car x)) (append (cons (car x) b) (cdr x)))
          (else (priority (append b (list (car x))) (cdr x)))))

  
  (define (form x)
    (cond ((not (list? x)) (list x))
          ((and (= (length x) 1) (list? (car x))) (car x))
          (else x)))

  
  (define (b-derivative x)
    (let ((x (form x)))
      (cond ((equal? x '()) '())
            ((= (length x) 1) (if (number? (car x))
                                  0
                                  1))
            ((= (length x) 2) (cond ((equal? (car x) 'log) (list '/ (derivative-rools (cdr x)) (cadr x)))
                                    ((equal? (car x) 'sin) (list '* (list 'cos (cadr x)) (derivative-rools (cdr x))))
                                    ((equal? (car x) 'cos) (list '* (list '- (list 'sin (cadr x))) (derivative-rools (cdr x))))
                                    ((equal? (car x) 'exp) (list '* x (derivative-rools (cdr x))))))
            (else (cond ((equal? (car x) 'expt) (if (number? (caddr x))
                                                    (list '* (caddr x) (list 'expt (cadr x) (- (caddr x) 1)) (derivative-rools (list (cadr x))))
                                                    (list '* x (list 'log (cadr x)) (derivative-rools (cddr x)))))
                        ((equal? (car x) 'log) (list '/ (derivative-rools (list (cadr x))) (list '* (cadr x) (list 'log (caddr x))))))))))


  (define (derivative-rools x)
    (let ((x (form x)))
      (cond ((equal? (car x) '-) (cons '- (map derivative-rools (cdr x))))
            ((equal? (car x) '+) (cons '+ (map derivative-rools (cdr x))))
            ((equal? (car x) '*) (let ((x (cons '* (priority '() (cdr x))))) (if (number? (cadr x))
                                     (if (= (length x)  3)
                                         (list '* (cadr x) (derivative-rools (cddr x)))
                                         (list '* (cadr x) (derivative-rools (cons '* (cddr x)))))
                                     (if (= (length x)  3)
                                         (list '+ (list '* (derivative-rools (cadr x)) (caddr x)) (list '* (derivative-rools (caddr x)) (cadr x)))
                                         (derivative-rools (list '* (cadr x) (derivative-rools (cons '* (cddr x)))))))))
            ((equal? (car x) '/) (cond ((number? (cadr x)) (if (= (length x)  3)
                                                               (list '/ (list '* (list '- (cadr x)) (derivative-rools (cddr x))) (list 'expt (caddr x) 2))
                                                               (list '/ (derivative-rools (cons '/ (cddr x))) (cadr x))))
                                       ((number? (caddr x)) (if (= (length x)  3)
                                                                (list '/ (derivative-rools (cadr x)) (caddr x))
                                                                (list '/ (derivative-rools (cons '/ (cons cadr (cdddr x))) (caddr x)))))
                                       (else (if (= (length x)  3)
                                                 (list '/ (list '- (list '* (derivative-rools (cadr x)) (caddr x)) (list '* (derivative-rools (caddr x)) (cadr x))) (list 'expt (caddr x) 2))
                                                 (derivative-rools (list '/ (cadr x) (cons '* (cddr x))))))))
            (else (b-derivative x)))))

  
  (derivative-rools x))


(define-syntax derivative-test
  (syntax-rules ()
    ((derivative-test argument expected call-arg)
     (test (round_1e-6 (eval `(let ((x call-arg))
                                ,(derivative 'argument))
                             ie))
           (round_1e-6 (eval '(let ((x call-arg))
                                expected)
                             ie))))))

(define PI (* 4 (atan 1)))

(define (round_1e-6 x)
  (/ (round (* x 1e6)) 1e6))


(display "\n-=РОБОТ-ПРОВЕРЯЛЬЩИК ВЫПОЛНЯЕТ ТЕСТЫ ДЛЯ ПРОИЗВОДНОЙ=-\n\n")


(define tests
  (list (derivative-test 2 0 10)
        (derivative-test x 1 10)
        (derivative-test (- x) -1 10)
        (derivative-test (* 1 x) 1 10)
        (derivative-test (* -1 x) -1 10)
        (derivative-test (* -4 x) -4 10)
        (derivative-test (* x 10) 10 10)
        (derivative-test (- (* 2 x) 3) 2 10)
        (derivative-test (expt x 10) (* 10 (expt x 9)) 10)
        (derivative-test (* 2 (expt x 5)) (* 10 (expt x 4)) 10)
        (derivative-test (expt x -2) (* -2 (expt x -3)) 10)
        (derivative-test (expt 5 x) (* (log 5) (expt 5 x)) 10)
        (derivative-test (cos x) (- (sin x)) (/ PI 2))
        (derivative-test (sin x) (cos x) 0)
        (derivative-test (exp x) (exp x) 10)
        (derivative-test (* 2 (exp x)) (* 2 (exp x)) 10)
        (derivative-test (* 2 (exp (* 2 x))) (* 4 (exp (* 2 x))) 10)
        (derivative-test (log x) (/ 1 x) 7)
        (derivative-test (* (log x) 3) (/ 3 x) 7)
        (derivative-test (+ (expt x 3) (* x x)) (+ (* 3 x x) (* 2 x)) 10)
        (derivative-test (- (* 2 (expt x 3)) (* 2 (expt x 2)))
                         (- (* 6 x x) (* 4 x))
                         10)
        (derivative-test (/ 3 x) (/ -3 (* x x)) 7)
        (derivative-test (/ 3 (* 2 (expt x 2))) (/ -3 (expt x 3)) 7)
        (derivative-test (* 2 (sin x) (cos x))
                         (* 2 (cos (* 2 x)))
                         (/ PI 3))
        (derivative-test (* 2 (exp x) (sin x) (cos x))
                         (* (exp x) (+ (* 2 (cos (* 2 x))) (sin (* 2 x))))
                         0)
        (derivative-test (cos (* 2 (expt x 2)))
                         (* -4 x (sin (* 2 (expt x 2))))
                         5)
        (derivative-test (sin (log (expt x 2)))
                         (/ (* 2 (cos (log (expt x 2)))) x)
                         15)
        (derivative-test (+ (sin (+ x x)) (cos (* x 2 x)))
                         (+ (* 2 (cos (* 2 x))) (* -4 (sin (* x 2 x)) x))
                         10)
        (derivative-test (* (sin (+ x x)) (cos (* x 2 x)))
                         (+ (* (- 1 (* 2 x)) (cos (* 2 x (- 1 x))))
                            (* (+ 1 (* 2 x)) (cos (* 2 x (+ 1 x)))))
                         5)))


(run-tests tests)
