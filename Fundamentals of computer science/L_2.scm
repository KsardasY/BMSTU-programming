;1
(display "#1 count\n")


(define (count x xs)
  (if (null? xs)
    0
    (if (equal? x (car xs))
        (+ (count x (cdr xs)) 1)
        (count x (cdr xs)))))


(display "(count 'a '(a b (a) d)) -> ")
(count 'a '(a b (a) d))


;2
(display "\n#2 delete\n")


(define (delete pred? xs)
  (if (null? xs)
      (list)
      (if (pred? (car xs))
          (delete pred? (cdr xs))
          (cons (car xs) (delete pred? (cdr xs))))))


(display "(delete even? '(1 2 3 4)) -> ")
(delete even? '(1 2 3 4))


;3
(display "\n#3 iterate\n")


(define (iterate f x n)
  (if (= n 0)
      '()
      (cons x (iterate f (f x) (- n 1)))))


(display "(iterate (lambda (x) (* 2 x)) 1 6) -> ")
(iterate (lambda (x) (* 2 x)) 1 6)


;4
(display "\n#4 intersperse\n")


(define (intersperse x xs)
  (if (<= (length xs) 1)
      xs
      (cons (car xs) (cons x (intersperse x (cdr xs))))))


(display "(intersperse 'x '(1 2 3 4)) -> ")
(intersperse 'x '(1 2 3 4))


;5
(display "\n#5 any/all\n")


(define (any? pred? xs)
  (if (null? xs)
      #f
      (or (pred? (car xs)) (all? pred? (cdr xs)))))


(define (all? pred? xs)
   (or (null? xs) (and (pred? (car xs)) (all? pred? (cdr xs))) ))


(display "(any? odd? '(1 3 5 7)) -> ")
(any? odd? '(1 3 5 7))
(display "(all? odd? '(0 2 4 6)) -> ")
(all? odd? '(0 2 4 6))


;#6 function
(display "\n#6 function\n")


(define (f x) (+ x 2))
(define (g x) (* x 3))
(define (h x) (- x))

(define (o . xs)
  (lambda (x)
    (if (null? xs)
        x
        ((car xs) ((apply o (cdr xs)) x)))))


(display "((o f g h) 1) -> ")
((o f g h) 1)
(display "((o f g) 1) -> ")
((o f g) 1)
(display "((o h) 1) -> ")
((o h) 1)
(display "((o) 1) -> ")
((o) 1)
