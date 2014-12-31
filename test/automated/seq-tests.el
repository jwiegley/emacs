;;; seq-tests.el --- Tests for sequences.el

;; Copyright (C) 2014 Free Software Foundation, Inc.

;; Author: Nicolas Petton <petton.nicolas@gmail.com>
;; Maintainer: emacs-devel@gnu.org

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for sequences.el

;;; Code:

(require 'ert)
(require 'seq)

(defmacro with-test-sequences (spec &rest body)
  "Successively bind VAR to a list, vector, and string built from SEQ.
Evaluate BODY for each created sequence.

\(fn (var seq) body)"
  (declare (indent 1) (debug ((symbolp form) body)))
  (let ((initial-seq (make-symbol "initial-seq")))
    `(let ((,initial-seq ,(cadr spec)))
       ,@(mapcar (lambda (s)
                   `(let ((,(car spec) (apply (function ,s) ,initial-seq)))
                      ,@body))
                 '(list vector string)))))

(defun same-contents-p (seq1 seq2)
  "Return t if SEQ1 and SEQ2 have the same contents, nil otherwise."
  (equal (append seq1 '()) (append seq2 '())))

(defun test-sequences-evenp (integer)
  "Return t if INTEGER is even."
  (eq (logand integer 1) 0))

(defun test-sequences-oddp (integer)
  "Return t if INTEGER is odd."
  (not (test-sequences-evenp integer)))

(ert-deftest test-seq-drop ()
  (with-test-sequences (seq '(1 2 3 4))
    (should (equal (seq-drop seq 0) seq))
    (should (equal (seq-drop seq 1) (seq-subseq seq 1)))
    (should (equal (seq-drop seq 2) (seq-subseq seq 2)))
    (should (seq-empty-p (seq-drop seq 4)))
    (should (seq-empty-p (seq-drop seq 10))))
  (with-test-sequences (seq '())
    (should (seq-empty-p (seq-drop seq 0)))
    (should (seq-empty-p (seq-drop seq 1)))))

(ert-deftest test-seq-take ()
  (with-test-sequences (seq '(2 3 4 5))
    (should (seq-empty-p (seq-take seq 0)))
    (should (= (seq-length (seq-take seq 1)) 1))
    (should (= (seq-elt (seq-take seq 1) 0) 2))
    (should (same-contents-p (seq-take seq 3) '(2 3 4)))
    (should (equal (seq-take seq 10) seq))))

(ert-deftest test-seq-drop-while ()
  (with-test-sequences (seq '(1 3 2 4))
    (should (equal (seq-drop-while #'test-sequences-oddp seq)
                   (seq-drop seq 2)))
    (should (equal (seq-drop-while #'test-sequences-evenp seq)
                   seq))
    (should (seq-empty-p (seq-drop-while #'numberp seq))))
  (with-test-sequences (seq '())
    (should (seq-empty-p (seq-drop-while #'test-sequences-oddp seq)))))

(ert-deftest test-seq-take-while ()
  (with-test-sequences (seq '(1 3 2 4))
    (should (equal (seq-take-while #'test-sequences-oddp seq)
                   (seq-take seq 2)))
    (should (seq-empty-p (seq-take-while #'test-sequences-evenp seq)))
    (should (equal (seq-take-while #'numberp seq) seq)))
  (with-test-sequences (seq '())
    (should (seq-empty-p (seq-take-while #'test-sequences-oddp seq)))))

(ert-deftest test-seq-filter ()
  (with-test-sequences (seq '(6 7 8 9 10))
    (should (equal (seq-filter #'test-sequences-evenp seq) '(6 8 10)))
    (should (equal (seq-filter #'test-sequences-oddp seq) '(7 9)))
    (should (equal (seq-filter (lambda (elt) nil) seq) '())))
  (with-test-sequences (seq '())
    (should (equal (seq-filter #'test-sequences-evenp seq) '()))))

(ert-deftest test-seq-remove ()
  (with-test-sequences (seq '(6 7 8 9 10))
    (should (equal (seq-remove #'test-sequences-evenp seq) '(7 9)))
    (should (equal (seq-remove #'test-sequences-oddp seq) '(6 8 10)))
    (should (same-contents-p (seq-remove (lambda (elt) nil) seq) seq)))
  (with-test-sequences (seq '())
    (should (equal (seq-remove #'test-sequences-evenp seq) '()))))

(ert-deftest test-seq-count ()
  (with-test-sequences (seq '(6 7 8 9 10))
    (should (equal (seq-count #'test-sequences-evenp seq) 3))
    (should (equal (seq-count #'test-sequences-oddp seq) 2))
    (should (equal (seq-count (lambda (elt) nil) seq) 0)))
  (with-test-sequences (seq '())
    (should (equal (seq-count #'test-sequences-evenp seq) 0))))

(ert-deftest test-seq-reduce ()
  (with-test-sequences (seq '(1 2 3 4))
    (should (= (seq-reduce #'+ seq 0) 10))
    (should (= (seq-reduce #'+ seq 5) 15)))
  (with-test-sequences (seq '())
    (should (eq (seq-reduce #'+ seq 0) 0))
    (should (eq (seq-reduce #'+ seq 7) 7))))

(ert-deftest test-seq-some-p ()
  (with-test-sequences (seq '(4 3 2 1))
    (should (= (seq-some-p #'test-sequences-evenp seq) 4))
    (should (= (seq-some-p #'test-sequences-oddp seq) 3))
    (should-not (seq-some-p (lambda (elt) (> elt 10)) seq)))
  (with-test-sequences (seq '())
    (should-not (seq-some-p #'test-sequences-oddp seq))))

(ert-deftest test-seq-contains-p ()
  (with-test-sequences (seq '(3 4 5 6))
    (should (seq-contains-p seq 3))
    (should-not (seq-contains-p seq 7)))
  (with-test-sequences (seq '())
    (should-not (seq-contains-p seq 3))
    (should-not (seq-contains-p seq nil))))

(ert-deftest test-seq-every-p ()
  (with-test-sequences (seq '(43 54 22 1))
    (should (seq-every-p (lambda (elt) t) seq))
    (should-not (seq-every-p #'test-sequences-oddp seq))
    (should-not (seq-every-p #'test-sequences-evenp seq)))
  (with-test-sequences (seq '(42 54 22 2))
    (should (seq-every-p #'test-sequences-evenp seq))
    (should-not (seq-every-p #'test-sequences-oddp seq)))
  (with-test-sequences (seq '())
    (should (seq-every-p #'identity seq))
    (should (seq-every-p #'test-sequences-evenp seq))))

(ert-deftest test-seq-empty-p ()
  (with-test-sequences (seq '(0))
    (should-not (seq-empty-p seq)))
  (with-test-sequences (seq '(0 1 2))
    (should-not (seq-empty-p seq)))
  (with-test-sequences (seq '())
    (should (seq-empty-p seq))))

(ert-deftest test-seq-sort ()
  (should (equal (seq-sort #'< "cbaf") "abcf"))
  (should (equal (seq-sort #'< '(2 1 9 4)) '(1 2 4 9)))
  (should (equal (seq-sort #'< [2 1 9 4]) [1 2 4 9]))
  (should (equal (seq-sort #'< "") "")))

(ert-deftest test-seq-uniq ()
  (with-test-sequences (seq '(2 4 6 8 6 4 3))
    (should (equal (seq-uniq seq) '(2 4 6 8 3))))
  (with-test-sequences (seq '(3 3 3 3 3))
    (should (equal (seq-uniq seq) '(3))))
  (with-test-sequences (seq '())
    (should (equal (seq-uniq seq) '()))))

(ert-deftest test-seq-subseq ()
  (with-test-sequences (seq '(2 3 4 5))
    (should (equal (seq-subseq seq 0 4) seq))
    (should (same-contents-p (seq-subseq seq 2 4) '(4 5)))
    (should (same-contents-p (seq-subseq seq 1 3) '(3 4)))
    (should (same-contents-p (seq-subseq seq 1 -1) '(3 4))))
  (should (vectorp (seq-subseq [2 3 4 5] 2)))
  (should (stringp (seq-subseq "foo" 2 3)))
  (should (listp (seq-subseq '(2 3 4 4) 2 3))))

(ert-deftest test-seq-concatenate ()
  (with-test-sequences (seq '(2 4 6))
    (should (equal (seq-concatenate 'string seq [8]) (string 2 4 6 8)))
    (should (equal (seq-concatenate 'list seq '(8 10)) '(2 4 6 8 10)))
    (should (equal (seq-concatenate 'vector seq '(8 10)) [2 4 6 8 10]))
    (should (equal (seq-concatenate 'vector nil '(8 10)) [8 10]))
    (should (equal (seq-concatenate 'vector seq nil) [2 4 6]))))

(provide 'seq-tests)
;;; seq-tests.el ends here