(require 'cl-macs)

(cl-defstruct old x)

(defun foo ()
  (make-old))

;;(byte-compile-file "old-struct.el")
;;(load-file "old-struct.elc")
;;(disassemble 'foo)
;;(cl-typep (foo) 'cl-structure-object)
;;(cl-struct-p (foo))
;;(memq (aref (foo) 0) cl-struct-cl-structure-object-tags)
;;(setq old-struct-compat t)
