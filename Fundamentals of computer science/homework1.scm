(define (day-of-week d m y)
  (if (< m 3)
      (remainder (+ d (quotient (* 31 (+ m 10)) 12) (- y 1) (quotient (- y 1) 4) (- (quotient (- y 1) 100)) (quotient (- y 1) 400)) 7)
      (remainder (+ d (quotient (* 31 (- m 2)) 12) y  (quotient y 4) (- (quotient y 100)) (quotient y 400)) 7)))


(define (equation a b c)
  (define D (- (* b b) (* 4 a c)))
  (if (< D 0)
      (list)
      (if (= D 0)
          (list (/ (- b) (* 2 a)))
          (list (/ (+ (- b) (sqrt D)) (* 2 a)) (/ (- (- b) (sqrt D)) (* 2 a)))
      )))


(define (fact x)
  (if (<= x 0)
      1
      (* x (fact (- x 1)))
      ))


(define (my-gcd a b)
  (if (= b 0)
      (abs a)
      (my-gcd b (remainder a b))
      ))


(define (my-lcm a b)
  (quotient (* a b) (my-gcd a b))
  )


(define (prime? x)
  (= (remainder (+ 1 (fact (- x 1))) x) 0))


(define (square x) (* x x))


(square 4)


(define (f a b c)
  (cond (a (* a a))
        (b (sqrt b))
        (c -)
        (else 0)))


(f -1.4122 9 5)


(define mul (lambda (x) (lambda (y) (* x y)))); == (define (mul x) (lambda (y) (* x y)))


((mul 7) 9)


(define double (mul 2))
(define triple (mul 3))


(double 7)
(triple 12)


(define (multi-apply f x n)
  (if (= n 0)
      x
      (f (multi-apply f x (- n 1)))))


(multi-apply square 3 3)
(multi-apply square 2 4)
(multi-apply (lambda (x) (+ 2 x)) 0 7)


(define (select n)
  (cond ((= n 0) +)
        ((= n 1) -)
        ((= n 2) (lambda (x y) (sqrt (+ (square x) (square y)))))
        (else (lambda (x y) 0))))


((select 0) 2 3 5)
((select 1) 10 7 8 -2)
((select 2) 3 4)


(define (pair x y)
  (lambda (f) (f x y)))


(define (first p)
  (p (lambda (x y) x)))


(define (second p)
  (p (lambda (x y) y)))


(define p1 (pair 2 3))
(first p1)


(define (swap p)
  (pair (second p) (first p)))


(define (S a b c)
  (let ((p (/ (+ a b c) 2)))
    (sqrt (* p (- p a) (- p b) (- p c)))))


(S 3 4 5)


(define (c a b)
  (let ((a2 (* a a))
        (b2 (* b b)))
    (sqrt (+ a2 b2))))


(c 12 5)
;let* - хз, что это


(define (P a)
  (let ((a a)
         (b (* a 2)))
    (* (+ a b) 2)))


(P 4)


(define (fact N)
  (define (loop i res)
    (if (<= i N)
        (loop (+ i 1)
              (* res i))
        res))
  (loop 1 1))


(list 1 2 3 4)
(cons 1 '(2 3 4))


(car (list 1 2 3 4))
(cdr (list 1 2 3 4))


(null? (list 1 2 3 4))
(null? (list))


(length '(1 1 2 1))


(append '(1 2 3) '(4 5 6))
(append '(1 2) '(3 4) '(5 6))


(map square '(1 2 3 4 5))
(map
  (lambda (x y) (+ (* 2 x) (* 3 y)))
  '(1 2 1 2)
  '(2 3 2 3 2)
)
((lambda xs xs) 1 2 3 4)
((lambda (a b c . xs)
   (list (+ a b c) xs))
 1 2 3 4 5)


(define (f . xs)
  (list xs xs))


(define x "32")
(define y x)


(eq? x y)
(eqv? x y)
(equal? x y)


(define xs '(a b c d))
(list-ref xs 2) 
