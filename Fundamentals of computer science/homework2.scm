;#1 list
(display "#1 list\n")


(define (my-range a b d)
  (if (>= a b)
      '()
      (cons a (my-range (+ a d) b d))))


(display "(my-range 2 8 3) -> ")
(my-range 2 8 3)


(define (my-flatten a)
  (cond ((not (pair? a)) a)
      ((pair? (car a)) (append (my-flatten (car a)) (my-flatten (cdr a))))
      ((equal? (car a) '()) (my-flatten (cdr a)))
      (else (cons (car a) (my-flatten (cdr a))))))


(display "(my-flatten '((1 2) () () (1) 3)) -> ")
(my-flatten '((1 2) () () (1) 3))


(define (my-element? x xs)
  (cond ((equal? xs '()) #f)
        ((equal? (car xs) x) #t)
        (else (my-element? x (cdr xs)))))


(display "(my-element? 1 '((1) 12)) -> ")
(my-element? 1 '((1) 12))


(define (my-filter pred? xs)
  (cond ((equal? xs '()) '())
        ((equal? (pred? (car xs)) #t) (cons (car xs) (my-filter pred? (cdr xs))))
        (else (my-filter pred? (cdr xs)))))


(display "(my-filter (lambda (x) (> x 2)) '(1 3 4 -4 0)) -> ")
(my-filter (lambda (x) (> x 2)) '(1 3 4 -4 0))


(define (my-fold-left op xs)
  (cond ((= (length xs) 1) (car xs))
        ((= (length xs) 2) (op (car xs) (cadr xs)))
        (else (my-fold-left op (cons (op (car xs) (cadr xs)) (cddr xs))))))


(display "(my-fold-left  expt '(2 3 4)) -> ")
(my-fold-left expt '(2 3 4))


(define (my-fold-right op xs)
  (cond ((= (length xs) 1) (car xs))
        ((= (length xs) 2) (op (car xs) (cadr xs)))
        (else (op (car xs) (my-fold-right op (cdr xs))))))


(display "(my-fold-right expt '(2 3 4)) -> ")
(my-fold-right expt '(2 3 4))


;#2 set
(display "\n#2 set\n")


(define (list->set xs)
  (if (null? xs)
      '()
      (if (my-element? (car xs) (cdr xs))
          (list->set (cdr xs))
          (cons (car xs) (list->set (cdr xs))))))



(display "(list->set '(3 1 2)) -> ")
(list->set '(3 1 2))


(define (set? xs)
  (cond
    ((null? xs) #t)
    ((my-element? (car xs) (cdr xs)) #f)
    (else (set? (cdr xs)))))


(display "(set? '(3 1 2)) -> ")
(set? '(3 1 2))


(define (union xs ys)
  (cond
    ((null? xs) ys)
    ((my-element? (car xs) ys) (union (cdr xs) ys))
    (else (cons (car xs) (union (cdr xs) ys)))))


(display "(union '(1 2 3) '(3 7 1)) -> ")
(union '(1 2 3) '(3 7 1))


(define (intersection xs ys)
  (cond
    ((or (null? xs) (null? ys)) '())
    ((my-element? (car xs) ys) (cons (car xs) (intersection (cdr xs) ys)))
    (else (intersection (cdr xs) ys))))


(display "(intersection '(1 2 3) '(3 7 1)) -> ")
(intersection '(1 2 3) '(3 7 1))


(define (difference xs ys)
  (cond
    ((null? xs) '())
    ((my-element? (car xs) ys) (difference (cdr xs) ys))
    (else (cons (car xs) (difference (cdr xs) ys)))))


(display "(difference '(1 2 3) '(3 7 1)) -> ")
(difference '(1 2 3) '(3 7 1))


(define (symmetric-difference xs ys)
  (union (difference xs ys) (difference ys xs)))


(display "(symmetric-difference '(1 2 3) '(3 7 1)) -> ")
(symmetric-difference '(1 2 3) '(3 7 1))


(define (set-eq? xs ys)
  (and (set? xs) (set? ys) (equal? (symmetric-difference xs ys) '())))


(display "(set-eq? '(1 2 3) '(3 1 2)) -> ")
(set-eq? '(1 2 3) '(3 1 2))


;#3 string
(display "\n#3 string\n")


(define (string-trim-left s)
  (if (char-whitespace? (string-ref s 0)) 
      (string-trim-left (substring s 1))
      s))


(define (string-trim-right s)
  (if (char-whitespace? (string-ref s (- (string-length s) 1)))
      (string-trim-right (substring s 0 (- (string-length s) 1)))
      s))


(define (string-trim s)
  (string-trim-left (string-trim-right s)))


(display "(string-trim-right \"ilovescheme \t\t\t   \") -> ")
(string-trim-right '"ilovescheme \t\t\t   ")
(display "(string-trim-left '\"\t\t\t      \tilovescheme\") -> ")
(string-trim-left '"\t\t\t      \tilovescheme")
(display "(string-trim '\"\t\t\t      \tilovescheme \t\t\t   \") -> ")
(string-trim '"\t\t\t      \tilovescheme \t\t\t   ")


(define (string-prefix? a b)
  (if (> (string-length a) (string-length b))
      #f
      (equal? (substring b 0 (string-length a)) a)))


(display "(string-prefix? \"ilovess\" \"ilovescheme\") -> ")
(string-prefix? "ilovess" "ilovescheme")


(define (string-suffix? a b)
  (cond
    ((> (string-length a) (string-length b)) #f)
    ((equal? (substring b (- (string-length b) (string-length a))) a) #t)
    (else #f)))


(display "(string-subfix? \"scheme\" \"ilovescheme\") -> ")
(string-suffix? "scheme" "ilovescheme")


(define (string-infix? a b)
  (cond
    ((> (string-length a) (string-length b)) #f)
    ((string-prefix? a b) #t)
    (else (string-infix? a (substring b 1)))))


(display "(string-infix? \"love\" \"ilovescheme\") -> ")
(string-infix? "love" "ilovescheme")


(define (add-elem s sep)
  (cond
    ((= (string-length s) 0) (string))
    ((string-prefix? sep s) (string))
    (else (string-append (make-string 1 (string-ref s 0)) (add-elem (substring s 1) sep)))))


(define (string-split s sep)
  (cond
    ((= (string-length s) 0) (list))
    ((string-prefix? sep s) (string-split (substring s (string-length sep)) sep))
    (else (cons (add-elem s sep) (string-split (substring s (string-length (add-elem s sep))) sep)))))


(display "(string-split \"sc;he;me\" \";\") -> ")
(string-split "sc;he;me" ";")


;#4 мусещк
(display "\n#4 vector\n")


(define (make-multi-vector sizes . fill) 
  (cons
   sizes
   (list (if (= (length fill) 1) 
             (make-vector (apply * sizes) (car fill))
             (make-vector (apply * sizes))))))


(define m (make-multi-vector '(1 2 3) 1))
(display "m -> ") (display m) (newline)


(define (multi-vector? mv)
  (and (list? mv) (list? (car mv)) (vector? (cadr mv))))


(display "(multi-vector? m) -> ")
(multi-vector? m)
(display "(multi-vector? #(1 1 1 1)) -> ")
(multi-vector? #(1 1 1 1))


(define (position-in-vector sizes indices)
  (if (null? (cdr sizes))
      (car sizes)
      (+ (* (car indices) (apply * (cdr sizes)))
         (position-in-vector (cdr sizes) (cdr indices)))))


(define (multi-vector-ref mv indices)
  (vector-ref (cadr mv) (position-in-vector (car mv) indices)))


(define m (make-multi-vector '(3 3 2 2) 1))
(display "(multi-vector-ref m '(0 0 0)) -> ")
(multi-vector-ref m '(0 0 0))


(define (multi-vector-set! mv indices x)
  (vector-set! (cadr mv) (position-in-vector (car mv) indices) x))


(multi-vector-set! m '(1 2 1 1) 'X)
(multi-vector-set! m '(2 1 1 1) 'Y)
(display "(multi-vector-ref m '(1 2 1 1)) -> ")
(multi-vector-ref m '(1 2 1 1))
(display "(multi-vector-ref m '(2 1 1 1)) -> ")
(multi-vector-ref m '(2 1 1 1))


;#5 function
(display "\n#5 function\n")


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
