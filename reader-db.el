;;; reader-db.el --- Simple one-file data base         -*- lexical-binding: t; -*-

;; Copyright (C) 2018-2019

;; Author:  Public Image Ltd. <joerg@joergvolbers.de>
;; Keywords: files, data
;; Version: 0.1
;; Package-Version: 0.1
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/publicimageltd/reader-db

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides a way too simple database to store values associated with
;; distinct keys (slots). This is not a replacement for a real data
;; base; it is mainly intented to store simple configuration
;; information.

;; The data is stored as a readable Lisp object. Thus, only printable
;; objects can be stored. All modifications of the data base rewrite
;; the complete file.

;; The data file has to be initialized with a definition object (an
;; alist) which defines the slots. The definition object might define
;; default values. See the variable `reader-db-definition' for an
;; example of the structure of that list.

;; Example usage:

;; (setq db-definition '((slot1) (slot2)))
;; (reader-db-init "filename" db-definition)
;; (reader-db-get "filename" 'slot1)               =>  nil
;; (reader-db-put  "filename" 'slot1 "new-value")
;; (reader-db-get "filename" 'slot1)                => "new-value"

;;; Code:

(defvar reader-db-definition
  '((var1 . "initial value")
    (var2 . :another-initial-value)
    (vara . '(lists have to be quoted))
    (var3 . (format "%s" "unqoted lists will be evaluated")))
  "Exemplary definition list for a reader db file.

See `reader-db-object' for an explanation of the syntax.")

(defun reader-db-object (definition &rest r)
  "Create an object to store in the reader file data base.

DEFINITION (alist) defines the slots to be used and possibly
assigns default values to them.

Valid definitions are, for example:

  (a) ((slot1) (slot2))  ;; slot1 and slot2 default to nil

  (b) ((slot1 . \"Initial value1\") (slot2))

All further arguments (R) are pairs which define a key (slot) and
assign a value to it. Keyword arguments override the default
values."
  (mapcar
   (lambda (def-item)
     (let (key val)
       (cons (setq key (car def-item))
	     (if (plist-member r key)
		 (plist-get r key)
	       (setq val (cdr def-item))
	       (if (listp val) (eval val) val)))))
   definition))

(defun reader-db-readable-object-p (lisp-object)
  "Test if LISP-OBJECT can be read using `read'."
  (let* ((pretty-printed-object (pp-to-string lisp-object)))
    (condition-case  err
	(equal lisp-object (car (read-from-string pretty-printed-object)))
      ((end-of-file scan-error invalid-read-syntax circular-list)
       nil)
      (error (error (error-message-string err))))))
      
(defun reader-db-write (filename lisp-object)
  "Write LISP-OBJECT to FILENAME."
  (let* ((coding-system-for-write 'binary)
	 (print-level nil)
	 (print-length nil)
	 (content (concat
		   (format ";;; reader db file created: %s at %s h"
			   (format-time-string "%x")
			   (format-time-string "%H:%M"))
		   "\n\n"
		   (pp-to-string lisp-object))))
    (with-temp-file filename
      (set-buffer-multibyte nil)
      (encode-coding-string content 'utf-8 nil (current-buffer)))
  lisp-object))

(defun reader-db-read (file-name)
  "Read FILE-NAME in DIR as Lisp expression."
  (when (file-exists-p file-name)
    (with-temp-buffer
      (insert-file-contents-literally file-name)
      (condition-case err
	  (car (read-from-string (decode-coding-region (point-min) (point-max) 'utf-8 t)))
	((end-of-file scan-error invalid-read-syntax circular-list)
	 (error "Probably corrupt data. File '%s' could not be read, returned error '%s'"
		file-name
		(error-message-string err)))
	(error (error "Error reading data base: %s" (error-message-string err)))))))

(defun reader-db-init (file definition &rest r)
  "Initialize the data base FILE with default content DEFINITION.

Further arguments (R) are a list of slot keywords and values to
override the default content.

See also the documentation of `reader-db-object'."
  (reader-db-write file (apply #'reader-db-object definition r)))

(defun reader-db-erase-db (file)
  "Delete the data base FILE."
  (when (file-exists-p file) (delete-file file)))

(defun reader-db-get (file slot)
  "Read the value of SLOT stored in FILE."
  (alist-get slot (reader-db-read file)))
	  
(defun reader-db-put (file slot val)
  "Store VAL in SLOT in FILE."
  (let ((db (reader-db-read file)))
    (setf (alist-get slot db) val)
    (reader-db-write file db)))

(provide 'reader-db)
;;; reader-db.el ends here
