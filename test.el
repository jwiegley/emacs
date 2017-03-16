(require 'eieio)

(let ((x (make-record 'foo 3 nil)))
  (aset x 1 1)
  (aset x 2 2)
  (aset x 3 3)
  (list (read-from-string (with-output-to-string (prin1 x)))
	(recordp x)
	(type-of x)
	(aref x 0)
	(aref x 3)
	(length x)))


(cl-defstruct foo x y z)
(let ((x (make-foo :y 1)))
  (list (type-of x)
	(foo-p x)
	(recordp x)
	(foo-y x)
	x))

(progn
  (cl-defstruct bar1 x)
  (make-bar1 :x 0))             ;#%[bar1 0]

(progn
  (cl-defstruct (bar2 :named) x)
  (make-bar2 :x 0))             ;#%[bar2 0]

(progn
  (cl-defstruct (bar3 (:type list)) x)
  (make-bar3 :x 0))             ;(0)

(progn
  (cl-defstruct (bar4 (:type list) :named) x)
  (make-bar4 :x 0))             ;(bar4 0)

(progn
  (cl-defstruct (bar5 (:type vector)) x)
  (make-bar5 :x 0))             ;[0]

(progn
  (cl-defstruct (bar6 (:type vector) :named) x)
  (make-bar6 :x 0))             ;[bar6 0]
