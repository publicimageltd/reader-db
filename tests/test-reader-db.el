;;; test-reader-db.el --- test readerdb              -*- lexical-binding: t; -*-


;;; Refer to tested file:
(require 'reader-db)

(require 'seq)

;;; Test Suites:

(describe "A lisp object"
  (it "will be correctly determined as readable for the lisp reader"
    (expect (with-temp-buffer (reader-db-readable-object-p (current-buffer)))
	    :to-be
	    nil)))

(describe "Basic File Handling"
  :var (file-name)
  (before-all
    (setq file-name (make-temp-file "test"))
    (setq object '(test-object "test-value" (test list))))
  ;;
  (after-all
    (when (file-exists-p file-name)
      (delete-file file-name)))
  ;;
  (it "tests that the DB file is written"
    (reader-db-write file-name object)
    (expect (file-exists-p file-name) :to-be-truthy))
  ;;
  (it "tests the content to be written correctly"
    (expect (with-temp-buffer
	      (insert-file-contents file-name)
	      (goto-char (point-min))
	      (read (current-buffer)))
	    :to-equal
	    object))
  ;;
  (it "tests how the content is read in"
    (expect (reader-db-read file-name)
	    :to-equal
	    object))
  ;;
  (it "tests that erasing the db works"
    (reader-db-erase-db file-name)
    (expect (file-exists-p file-name)
	    :not :to-be-truthy))
  ;;
  (it "tests the initializaiton of a new db (standard way)"
    (reader-db-init file-name '((slot1 . "init-value1")))
    (expect (cdr (assoc 'slot1 (reader-db-read file-name)))
	    :to-equal
	    "init-value1"))
  ;;
  (it "tests the initialization of a new db (with keywords)"
    (reader-db-init file-name '((slot1)) 'slot1 "value")
    (expect (cdr (assoc 'slot1 (reader-db-read file-name)))
	    :to-equal
	    "value")))

;; --------------------------------------------------------------------------------

(describe "Writing and storing values"
  :var (file-name definition)
  ;;
  (before-all
    (setq definition '((slot1) (slot2)))
    (setq file-name (make-temp-file "test"))
    (reader-db-init file-name definition))
  ;;
  (after-all
    (when (file-exists-p file-name)
      (delete-file file-name)))
  ;;
  (it "checks for a stored value"
    (reader-db-put file-name 'slot1 "new-value")
    (expect (cdr (assoc 'slot1 (reader-db-read file-name)))
	    :to-equal
	    "new-value"))
  ;;
  (it "checks for another stored value"
    (reader-db-put file-name 'slot2 "newest-value")
    (expect (cdr (assoc 'slot2 (reader-db-read file-name)))
	    :to-equal
	    "newest-value"))
  ;;
  (it "checks for reading a stored value"
    (reader-db-put file-name 'slot1 "another value")
    (expect (reader-db-get file-name 'slot1)
	    :to-equal
	    "another value"))
  ;;
  (it "checks for reading another stored value"
    (reader-db-put file-name 'slot2 "yet another value")
    (expect (reader-db-get file-name 'slot2)
	    :to-equal
	    "yet another value")))

(describe "handling of definition lists"
  :var (own-definition)
  (before-all
    (setq own-definition '((slot1 . "value1"))))
  ;;
  (it "tests for the correct format of the example definition"
    (expect (boundp 'reader-db-definition)
	    :to-be-truthy)
    (expect (listp reader-db-definition)
	    :to-be-truthy)
    (expect (seq-count #'consp reader-db-definition)
	    :to-equal
	    (seq-count #'listp reader-db-definition)))
  ;;
  (it "tests the correct creation of db objects"
    (expect (reader-db-object own-definition)
	    :to-equal
	    own-definition)
    (expect (cdr (assoc 'slot1
			(reader-db-object own-definition 'slot1 "new-value")))
	    :to-equal
	    "new-value")))

	    
   
	    





;;; test-reader-db.el ends here
